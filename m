Date: Sat, 16 Dec 2006 19:18:19 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.19 file content corruption on ext3
In-Reply-To: <20061216184310.GA891@unjust.cyrius.com>
Message-ID: <Pine.LNX.4.64.0612161909460.25272@blonde.wat.veritas.com>
References: <20061207155740.GC1434@torres.l21.ma.zugschlus.de>
 <4578465D.7030104@cfl.rr.com> <20061209092639.GA15443@torres.l21.ma.zugschlus.de>
 <20061216184310.GA891@unjust.cyrius.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Michlmayr <tbm@cyrius.com>
Cc: Marc Haber <mh+linux-kernel@zugschlus.de>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Dec 2006, Martin Michlmayr wrote:
> * Marc Haber <mh+linux-kernel@zugschlus.de> [2006-12-09 10:26]:
> > Unfortunately, I am lacking the knowledge needed to do this in an
> > informed way. I am neither familiar enough with git nor do I possess
> > the necessary C powers.
> 
> I wonder if what you're seein is related to
> http://lkml.org/lkml/2006/12/16/73
> 
> You said that you don't see any corruption with 2.6.18.  Can you try
> to apply the patch from
> http://www2.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=d08b3851da41d0ee60851f2c75b118e1f7a5fc89
> to 2.6.18 to see if the corruption shows up?

I did wonder about the very first hunk of Peter's patch, where the
mapping->private_lock is unlocked earlier now in try_to_free_buffers,
before the clear_page_dirty.  I'm not at all familiar with that area,
I wonder if Jan has looked at that change, and might be able to say
whether it's good or not (earlier he worried about his JBD changes,
but they wouldn't be implicated if just 2.6.18+Peter's gives trouble).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
