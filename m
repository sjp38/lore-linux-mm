From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Mon, 7 Jul 2003 17:28:08 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <Pine.LNX.4.53.0307071408440.5007@skynet> <Pine.LNX.4.55.0307070745250.4428@bigblue.dev.mcafeelabs.com>
In-Reply-To: <Pine.LNX.4.55.0307070745250.4428@bigblue.dev.mcafeelabs.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307071728.08753.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>, Mel Gorman <mel@csn.ul.ie>
Cc: Jamie Lokier <jamie@shareable.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 07 July 2003 16:47, Davide Libenzi wrote:
> On Mon, 7 Jul 2003, Mel Gorman wrote:
> > On Mon, 7 Jul 2003, Daniel Phillips wrote:
> > > And set up distros to grant it by default.  Yes.
> > >
> > > The problem I see is that it lets user space priorities invade the
> > > range of priorities used by root processes.
> >
> > That is the main drawback all right but it could be addressed by having a
> > CAP_SYS_USERNICE capability which allows a user to renice only their own
> > processes to a highest priority of -5, or some other reasonable value
> > that wouldn't interfere with root processes. This capability would only
> > be for applications like music players which need to give hints to the
> > scheduler.
>
> The scheduler has to work w/out external input, period. If it doesn't we
> have to fix it and not to force the user to submit external hints.

That's not correct in this case, because the sound servicing routine is 
realtime, which makes it special.  Furthermore, Zinf is already trying to 
provide the kernel with the hint it needs via PThreads SetPriority but 
because Linux has brain damage - both in the kernel and user space imho - the 
hint isn't accomplishing what it's supposed to.

As I said earlier: trying to detect automagically which threads are realtime 
and which aren't is stupid.  Such policy decisions don't belong in the 
kernel.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
