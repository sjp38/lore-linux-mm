Message-ID: <491F704A.3010201@redhat.com>
Date: Sat, 15 Nov 2008 19:58:50 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: evict streaming IO cache first
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi Andrew,
> 
> I think we need this patch at 2.6.28.

I agree.  I thought we would need this patch from right before
the time I wrote it, but we had no good workload to demonstrate
it at the time.

Gene Heskett found that the problem happens on his system and
the patch fixes is.

> Can this thinking get acception?

One of the reasons that I could not find a justification for
the patch is that all the benchmarks that I tried were
unaffected by it.  This makes me believe that the risk of
performance regressions is low, while the patch does fix a
real performance bug for Gene's desktop.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
