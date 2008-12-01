Date: Mon, 1 Dec 2008 07:40:41 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max
 pages
In-Reply-To: <49316CAF.2010006@redhat.com>
Message-ID: <Pine.LNX.4.64.0812010736240.11954@quilx.com>
References: <20081128140405.3D0B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <492FCFF6.1050808@redhat.com> <20081129164624.8134.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <49316CAF.2010006@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Sat, 29 Nov 2008, Rik van Riel wrote:

> When using mmap or memory hogs writing to swap, applications
> will not be throttled by the "too many dirty pages" logic,
> but may instead end up being throttled in the direct reclaim
> path instead.

The too many dirty pages logic will throttle applications dirtying
mmapped pages these days.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
