class StateMachine(object):

    def __init__(self,
                 initial_state,
                 state_changed=None,
                 before_state=None,
                 after_state=None,
                 after_finish=None,
                 after_error=None,
                 after_all=None):
        self._states = dict()
        self._finished = False
        self.initial_state = initial_state
        self.state_changed = state_changed
        self.before_state = before_state
        self.after_state = after_state
        self.after_finish = after_finish
        self.after_error = after_error
        self.after_all = after_all

    def add_state(self, state, runner):
        self._states[state] = runner

    def finish(self):
        self._finished = True

    def _do_run(self):
        state = self.initial_state

        self._state_changed(None, state)

        while not self._finished:
            runner = self._states[state]

            data = self._before_state(state)

            prev_state = state
            state = self._call_runner(runner, state, *data)

            self._after_state(prev_state, *data)

            if prev_state != state:
                self._state_changed(prev_state, state, *data)

        self._state_changed(state, None, *data)

    def _before_state(self, state):
        if self.before_state:
            return self.before_state(state),
        else:
            return tuple()

    def _call_runner(self, runner, state, *data):
        new_state = runner(*data)

        return new_state if new_state is not None else state

    def _after_state(self, state, *data):
        if self.after_state:
            self.after_state(state, *data)

    def _state_changed(self, previous, current, *data):
        if self.state_changed:
            self.state_changed(previous, current, *data)

    def run(self):
        exception = None
        try:
            self._do_run()
            self._after_finish()
        except Exception as e:
            exception = e
            handled = self._after_error(e)
            if not handled:
                raise e
        finally:
           self._after_all(exception)

    def _after_finish(self):
        if self.after_finish:
            self.after_finish()

    def _after_error(self, exception):
        if self.after_error:
            return self.after_error(exception)
        else:
            return False

    def _after_all(self, exception):
        if self.after_all:
            self.after_all(exception)

