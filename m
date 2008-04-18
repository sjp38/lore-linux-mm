Message-ID: <48083506.7080909@cn.fujitsu.com>
Date: Fri, 18 Apr 2008 13:43:34 +0800
From: Shi Weihua <shiwh@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcgroup: check and initialize page->cgroup in memmap_init_zone
References: <48080706.50305@cn.fujitsu.com>	<48080930.5090905@cn.fujitsu.com>	<48080B86.7040200@cn.fujitsu.com>	<20080417201432.36b1c326.akpm@linux-foundation.org>	<20080418123256.da4d1db0.kamezawa.hiroyu@jp.fujitsu.com> <20080418140946.e265c1f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080418140946.e265c1f3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote::
> On Fri, 18 Apr 2008 12:32:56 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>>> Or perhaps that page was used and then later freed before we got to
>>> memmap_init_zone() and was freed with a non-zero ->page_cgroup.  Which is
>>> unlikely given that page.page_cgroup was only just added and is only
>>> present if CONFIG_CGROUP_MEM_RES_CTLR.
>>>
>> Hmm, I'll try his .config and see what happens.
>>
> I reproduced the hang with his config and confirmed his fix works well.
> But I can't find why...I'll dig a bit more.

If i use CONFIG_SPARSEMEM instead of CONFIG_DISCONTIGMEM, the kernel 
boots successfully.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
