Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: broken VM in 2.4.10-pre9
Date: Wed, 19 Sep 2001 11:45:44 +0200
References: <878A2048A35CD141AD5FC92C6B776E4907BB98@xchgind02.nsisw.com> <m166ahst39.fsf@frodo.biederman.org>
In-Reply-To: <m166ahst39.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010919093828Z17304-2759+92@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, Rob Fuller <rfuller@nsisoftware.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 17, 2001 06:03 pm, Eric W. Biederman wrote:
> In linux we have avoided reverse maps (unlike the BSD's) which tends
> to make the common case fast at the expense of making it more
> difficult to handle times when the VM system is under extreme load and
> we are swapping etc.

What do you suppose is the cost of the reverse map?  I get the impression you 
think it's more expensive than it is.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
