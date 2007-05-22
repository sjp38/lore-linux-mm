From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: swap prefetch improvements
Date: Tue, 22 May 2007 20:20:57 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070521160029.GA28715@elte.hu> <5486cca80705220315oe4a42a2x366cff682333075c@mail.gmail.com>
In-Reply-To: <5486cca80705220315oe4a42a2x366cff682333075c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705222020.58474.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Antonino Ingargiola <tritemio@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 22 May 2007 20:15, Antonino Ingargiola wrote:
> 2007/5/21, Ingo Molnar <mingo@elte.hu>:
> > * Con Kolivas <kernel@kolivas.org> wrote:
> > > > A suggestion for improvement: right now swap-prefetch does a small
> > > > bit of swapin every 5 seconds and stays idle inbetween. Could this
> > > > perhaps be made more agressive (optionally perhaps), if the system
> > > > is not swapping otherwise? If block-IO level instrumentation is
> > > > needed to determine idleness of block IO then that is justified too
> > > > i think.
> > >
> > > Hmm.. The timer waits 5 seconds before trying to prefetch, but then
> > > only stops if it detects any activity elsewhere. It doesn't actually
> > > try to go idle in between but it doesn't take much activity to put it
> > > back to sleep, hence detecting yet another "not quite idle" period and
> > > then it goes to sleep again. I guess the sleep interval can actually
> > > be changed as another tunable from 5 seconds to whatever the user
> > > wanted.
> >
> > there was nothing else running on the system - so i suspect the swapin
> > activity flagged 'itself' as some 'other' activity and stopped? The
> > swapins happened in 4 bursts, separated by 5 seconds total idleness.
>
> I've noted burst swapins separated by some seconds of pause in my
> desktop system too (with sp_tester and an idle gnome).

That really is expected, as just about anything, including journal writeout, 
would be enough to put it back to sleep for 5 more seconds.
-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
