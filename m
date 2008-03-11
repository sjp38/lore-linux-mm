Message-ID: <47D6443D.9000904@openvz.org>
Date: Tue, 11 Mar 2008 11:35:09 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Move memory controller allocations to their own slabs
 (v2)
References: <20080311061836.6664.5072.sendpatchset@localhost.localdomain> <47D63E9D.70500@openvz.org> <47D63FB1.7040502@linux.vnet.ibm.com>
In-Reply-To: <47D63FB1.7040502@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Pavel Emelyanov wrote:
>> Balbir Singh wrote:
>>> Move the memory controller data structure page_cgroup to its own slab cache.
>>> It saves space on the system, allocations are not necessarily pushed to order
>>> of 2 and should provide performance benefits. Users who disable the memory
>>> controller can also double check that the memory controller is not allocating
>>> page_cgroup's.
>> Can you, please, check how many objects-per-page we have with and 
>> without this patch for SLAB and SLUB?
>>
>> Thanks.
> 
> I can for objects-per-page with this patch for SLUB and SLAB. I am not sure
> about what to check for without this patch. The machine is temporarily busy,

Well, the objects-per-page without the patch is objects-per-page for
according kmalloc cache :)

> I'll check it once I get it back.
> 

Ok, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
