Message-ID: <492AFE04.10404@redhat.com>
Date: Mon, 24 Nov 2008 14:18:28 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after swap_cluster_max
 pages
References: <20081116163915.F208.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <20081115235410.2d2c76de.akpm@linux-foundation.org>	 <20081122191258.26B0.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <49283A05.1060009@redhat.com> <2f11576a0811241112p494b28a6p720da1d60ac3438c@mail.gmail.com>
In-Reply-To: <2f11576a0811241112p494b28a6p720da1d60ac3438c@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> 1. reclaim 32 page from ZONE_HIGHMEM
> 2. reclaim 32 page from ZONE_NORMAL
> 3. reclaim 32 page from ZONE_DMA
> 4. exit reclaim
> 5. another task call page alloc and it cause try_to_free_pages()
> 6. reclaim 32 page from ZONE_HIGHMEM
> 7. reclaim 32 page from ZONE_NORMAL
> 8. reclaim 32 page from ZONE_DMA

>> - have direct reclaim tasks continue when priority == DEF_PRIORITY
> 
> disagreed.
> it cause above bad scenario, I think.

I think I did not explain it clearly.  Let me illustrate
with a new patch.  (one moment :))

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
