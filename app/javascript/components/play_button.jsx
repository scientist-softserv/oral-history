import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

export default class PlayButton extends React.Component {
  render() {
    return (
      <div className="player">
        <a className="play-icon" onClick={this.handleOnClick.bind(this)}>
          <i className="fa fa-play-circle-o g-font-size-18"></i>
        </a>
      </div>
    )
  }

  handleOnClick(e) {
    const { id, src } = this.props

    var event = new CustomEvent(
      'set_audio_player_src',
      {
        bubbles: true,
        cancelable: true,
        detail: { id, src }
      },
    )

    window.dispatchEvent(event)
  }
}
