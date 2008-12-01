Message-ID: <4933F9A1.6080106@redhat.com>
Date: Mon, 01 Dec 2008 09:50:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/11] make get_scan_ratio() to memcg safe
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081201211342.1CD6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081201211342.1CD6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Currently, get_scan_ratio() always calculate the balancing value for global reclaim and
> memcg reclaim doesn't use it.
> Therefore it doesn't have scan_global_lru() condition.
> 
> However, we plan to expand get_scan_ratio() to be usable for memcg too, latter.
> Then, The dependency code of global reclaim in the get_scan_ratio() insert into
> scan_global_lru() condision explictly.
> 
> 
> this patch doesn't have any functional change.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Good in principle, though of course this particular corner
case is not going to change when reclaiming a memcg :)

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
