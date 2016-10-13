import React from 'react';

class AvailableButton extends React.Component {
    render() {
        return (
            <div className="bottom-controls fixed">
                <button className="btn btn-lg btn-success btn-api" onClick={this.props.submitAvailable}>Start driving</button>
            </div>
        )
    }
};

export default AvailableButton;
