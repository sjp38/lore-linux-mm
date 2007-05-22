From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: swap prefetch improvements
Date: Tue, 22 May 2007 20:37:54 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705222020.58474.kernel@kolivas.org> <20070522102530.GB2344@elte.hu>
In-Reply-To: <20070522102530.GB2344@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705222037.54741.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Antonino Ingargiola <tritemio@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 22 May 2007 20:25, Ingo Molnar wrote:
> * Con Kolivas <kernel@kolivas.org> wrote:
> > > > there was nothing else running on the system - so i suspect the
> > > > swapin activity flagged 'itself' as some 'other' activity and
> > > > stopped? The swapins happened in 4 bursts, separated by 5 seconds
> > > > total idleness.
> > >
> > > I've noted burst swapins separated by some seconds of pause in my
> > > desktop system too (with sp_tester and an idle gnome).
> >
> > That really is expected, as just about anything, including journal
> > writeout, would be enough to put it back to sleep for 5 more seconds.
>
> note that nothing like that happened on my system - in the
> swap-prefetch-off case there was _zero_ IO activity during the sleep
> period.

Ok, granted it's _very_ conservative. I really don't want to risk its presence 
being a burden on anything, and the iowait it induces probably makes it turn 
itself off for another PREFETCH_DELAY (5s). I really don't want to cross the 
line to where it is detrimental in any way. Not dropping out on a 
cond_resched and perhaps making the delay tunable should be enough to make it 
a little less "sleepy".

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
