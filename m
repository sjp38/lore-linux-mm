Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6809B6B006A
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 08:41:48 -0500 (EST)
Received: by gv-out-0910.google.com with SMTP id l14so427127gvf.19
        for <linux-mm@kvack.org>; Fri, 13 Nov 2009 05:41:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091113133211.GA8742@kernel.dk>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
	 <1258054235-3208-4-git-send-email-mel@csn.ul.ie>
	 <20091113142526.33B3.A69D9226@jp.fujitsu.com>
	 <20091113115558.GY8742@kernel.dk> <20091113122821.GC29804@csn.ul.ie>
	 <20091113133211.GA8742@kernel.dk>
Date: Fri, 13 Nov 2009 15:41:46 +0200
Message-ID: <84144f020911130541p42c0b3d5lc307f97f22e2d356@mail.gmail.com>
Subject: Re: [PATCH 3/5] page allocator: Wait on both sync and async
	congestion after direct reclaim
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Jens,

On Fri, Nov 13, 2009 at 3:32 PM, Jens Axboe <jens.axboe@oracle.com> wrote:
>> Suggest an alternative that brings congestion_wait() more in line with
>> 2.6.30 behaviour then.
>
> I don't have a good explanation as to why the delays have changed,
> unfortunately. Are we sure that they have between .30 and .31? The
> dm-crypt case is overly complex and lots of changes could have broken
> that house of cards.

Hand-waving or not, we have end user reports stating that reverting
commit 8aa7e847d834ed937a9ad37a0f2ad5b8584c1ab0 ("Fix
congestion_wait() sync/async vs read/write confusion") fixes their
(rather serious) OOM regression. The commit in question _does_
introduce a functional change and if this was your average regression,
people would be kicking and screaming to get it reverted.

So is there a reason we shouldn't send a partial revert of the commit
(switching to BLK_RW_SYNC) to Linus until the "real" issue gets
resolved? Yes, I realize it's ugly voodoo magic but dammit, it used to
work!

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
