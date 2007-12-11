Date: Tue, 11 Dec 2007 14:29:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][for -mm] fix accounting in vmscan.c for memory
 controller
Message-Id: <20071211142911.4b8091d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <475E1CBC.4070408@linux.vnet.ibm.com>
References: <20071211112644.221a8dc5.kamezawa.hiroyu@jp.fujitsu.com>
	<475E1CBC.4070408@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Dec 2007 10:44:36 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Looks good to me.
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> TODO:
> 
> 1. Should we have vm_events for the memory controller as well?
>    May be in the longer term
> 

ALLOC_STALL is recoreded as failcnt, I think.
I think DIRECT can be accoutned easily.

But I'm not in hurry very much, because all reclaimation is DIRECT, now.
After we implement background reclaim, we should consider it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
