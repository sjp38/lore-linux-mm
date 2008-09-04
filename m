Date: Thu, 04 Sep 2008 17:11:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for allocation by the reclaimer
In-Reply-To: <48BEFAF9.3030006@linux-foundation.org>
References: <1220475206-23684-1-git-send-email-apw@shadowen.org> <48BEFAF9.3030006@linux-foundation.org>
Message-Id: <20080904170016.B265.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Cristoph

> How does page allocator fastpath behavior fare with this pathch?

Don't worry it because

1. shrink_zone() isn't fastpath because any reclaim isn't fastpath.
2. buddy combining on __free_one_page() isn't fastpath because
   any buddy combining isn't fastpath. (*)

(*)
all modern allocator have delayed buddy combining mecanism
because buddy combining increase cache miss.
(please imazine address X+1 is freed when address X is cold.
 combining cause next alloc get address X, then caller see cold page)

at least, allocator's fastpath should avoid its combining IMHO.

Unfortunately the linux buddy's one is limited because
zone->pcp only cache order-0 page.

Then, higher order pages's free always use slow path now.
but it isn't his patch failure.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
