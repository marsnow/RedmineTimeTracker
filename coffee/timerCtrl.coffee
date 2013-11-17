timeTracker.controller('TimerCtrl', ['$scope', '$account', '$redmine', '$ticket', '$message', ($scope, $account, $redmine, $ticket, $message) ->

  # ONE_MINUTE = 1
  ONE_MINUTE = 0 # for develop
  COMMENT_MAX = 255

  $scope.isTracking = false
  $scope.comment = ""
  $scope.commentMaxLength = COMMENT_MAX
  $scope.commentRemain = COMMENT_MAX

  _redmine = null


  ###
   get issues from redmine server.
  ###
  getIssues = ->
    $account.getAccounts (accounts) ->
      if not accounts? or not accounts?[0]? then return
      url    = accounts[0].url
      apiKey = accounts[0].apiKey
      userId = accounts[0].userId
      _redmine = $redmine(accounts[0])
      _redmine.issues.getOnUser(successGetIssues)


  ###
   merge ticket on strage, and update view
  ###
  successGetIssues = (data, status, headers, config) ->
    if not data?.issues? then return
    $ticket.addArray data.issues
    $scope.tickets = $ticket.getSelectable()
    $scope.selectedTicket = $ticket.getSelected()
    $ticket.sync()


  ###
   Start or End Time tracking
  ###
  $scope.clickSubmitButton = () ->
    if $scope.isTracking
      $scope.isTracking = false
      $scope.$broadcast 'timer-stop'
    else
      $scope.isTracking = true
      $scope.$broadcast 'timer-start'


  ###
   on timer stopped, send time entry.
  ###
  $scope.$on 'timer-stopped', (e, time) ->
    if _redmine? and time.minutes >= ONE_MINUTE
      hours = time.minutes / 60
      _redmine.issues.submitTime($scope.selectedTicket[0].id, $scope.comment, hours, submitSuccess, submitError)
      $message.toast "Submitting #{$scope.selectedTicket[0].subject}: #{hours} hr"
    else
      $message.toast 'Too short time entry.'


  ###
   show success message.
  ###
  submitSuccess = (msg) ->
    if msg?.time_entry?.id?
      $message.toast "Time Entry Saved."
    else
      submitError msg


  ###
   show failed message.
  ###
  submitError = (msg) ->
    $message.toast "Save Failed."


  ###
   on ticket loaded from crome storage, start getting issues.
  ###
  $scope.$on 'ticketLoaded', () ->
    getIssues()


  ###
   on account changed, start getting issues.
  ###
  $scope.$on 'accountChanged', () ->
    getIssues()


])
