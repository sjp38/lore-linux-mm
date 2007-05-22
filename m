Date: Tue, 22 May 2007 12:46:48 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: swap prefetch improvements
Message-ID: <20070522104648.GA10622@elte.hu>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705222020.58474.kernel@kolivas.org> <20070522102530.GB2344@elte.hu> <200705222037.54741.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705222037.54741.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Antonino Ingargiola <tritemio@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Con Kolivas <kernel@kolivas.org> wrote:

> On Tuesday 22 May 2007 20:25, Ingo Molnar wrote:
> > * Con Kolivas <kernel@kolivas.org> wrote:
> > > > > there was nothing else running on the system - so i suspect the
> > > > > swapin activity flagged 'itself' as some 'other' activity and
> > > > > stopped? The swapins happened in 4 bursts, separated by 5 seconds
> > > > > total idleness.
> > > >
> > > > I've noted burst swapins separated by some seconds of pause in my
> > > > desktop system too (with sp_tester and an idle gnome).
> > >
> > > That really is expected, as just about anything, including journal
> > > writeout, would be enough to put it back to sleep for 5 more seconds.
> >
> > note that nothing like that happened on my system - in the
> > swap-prefetch-off case there was _zero_ IO activity during the sleep
> > period.
> 
> Ok, granted it's _very_ conservative. [...]

but your first reaction was "it should not have slept for 5 seconds":

| Hmm.. The timer waits 5 seconds before trying to prefetch, but then 
| only stops if it detects any activity elsewhere. It doesn't actually 
| try to go idle in between
 
It clearly should not consider 'itself' as IO activity. This suggests 
some bug in the 'detect activity' mechanism, agreed? I'm wondering 
whether you are seeing the same problem, or is all swap-prefetch IO on 
your system continuous until it's done [or some other IO comes 
inbetween]?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
