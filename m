From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 9 Sep 2008 21:30:12 +0900 (JST)
Subject: Re: Re: [RFC][PATCH] Remove cgroup member from struct page
In-Reply-To: <48C66AF8.5070505@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48C66AF8.5070505@linux.vnet.ibm.com>
 <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809091358.28350.nickpiggin@yahoo.com.au> <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com> <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>> Balbir, are you ok to CONFIG_CGROUP_MEM_RES_CTLR depends on CONFIG_SPARSEME
M ?
>> I thinks SPARSEMEM(SPARSEMEM_VMEMMAP) is widely used in various archs now.
>
>Can't we make it more generic. I was thinking of allocating memory for each n
ode
>for page_cgroups (of the size of spanned_pages) at initialization time. I've 
not
>yet prototyped the idea. BTW, even with your approach I fail to see why we ne
ed
>to add a dependency on CONFIG_SPARSEMEM (but again it is 4:30 in the morning 
and
>I might be missing the obvious)

Doesn't have big issue without CONFIG_SPARSEMEM, maybe.
Sorry for my confusion.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
