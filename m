Date: Mon, 7 Jul 2003 20:39:11 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: 2.5.74-mm1
Message-ID: <20030707193911.GB10836@mail.jlokier.co.uk>
References: <20030703023714.55d13934.akpm@osdl.org> <20030707152339.GA9669@mail.jlokier.co.uk> <Pine.LNX.4.55.0307071007140.4704@bigblue.dev.mcafeelabs.com> <200307071955.58774.phillips@arcor.de> <Pine.LNX.4.55.0307071105110.4704@bigblue.dev.mcafeelabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.55.0307071105110.4704@bigblue.dev.mcafeelabs.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Daniel Phillips <phillips@arcor.de>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Davide Libenzi wrote:
> Try to play with SNDCTL_DSP_SETFRAGMENT. Last time I checked the kernel
> let you set a dma buf for 0.5 up to 1 sec of play (upper limited by 64Kb).
> Feeding the sound card with 4Kb writes will make you skip after about 50ms
> CPU blackout at 44KHz 16 bit. RealPlayer uses 16Kb feeding chunks that
> makes it able to sustain up to 200ms of blackout.

Large buffers are fine for streaming, provided you aren't sliding the
volume or graphic equaliser.  I find xmms annoying in this regard: I
adjust the eq and wait some absurd length of time (fully tenths of a
second :) to hear the feedback.

Large buffers are useless for games or telephony.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
