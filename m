From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Sun, 6 Jul 2003 15:54:48 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <200307060414.34827.phillips@arcor.de> <Pine.LNX.4.55.0307051918310.4599@bigblue.dev.mcafeelabs.com>
In-Reply-To: <Pine.LNX.4.55.0307051918310.4599@bigblue.dev.mcafeelabs.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307061554.48126.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Jamie Lokier <jamie@shareable.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 06 July 2003 04:21, Davide Libenzi wrote:
> On Sun, 6 Jul 2003, Daniel Phillips wrote:
> > On Sunday 06 July 2003 03:28, Jamie Lokier wrote:
> > > Your last point is most important.  At the moment, a SCHED_RR process
> > > with a bug will basically lock up the machine, which is totally
> > > inappropriate for a user app.
> >
> > How does the lockup come about?  As defined, a single SCHED_RR process
> > could lock up only its own slice of CPU, as far as I can see.
>
> They're de-queued and re-queue in the active array w/out having dynamic
> priority adjustment (like POSIX states). This means that any task with
> lower priority will starve if the RR task will not release the CPU.

OK, I see, I didn't pay close enough attention to the "it will be put at the 
end of the list _for its priority_" part.

So SCHED_RR is broken by design, too bad.  Now, how would SCHED_RR_NOTBROKEN 
work?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
