Message-ID: <4933FA32.3040004@redhat.com>
Date: Mon, 01 Dec 2008 09:52:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] memcg: add null check to page_cgroup_zoneinfo()
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081201211424.1CD9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081201211424.1CD9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> if CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y, page_cgroup::mem_cgroup can be NULL.
> Therefore null checking is better.
> 
> latter patch use this function.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
