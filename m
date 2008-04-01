Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v3)
In-Reply-To: Your message of "Tue, 01 Apr 2008 11:13:24 +0530"
	<20080401054324.829.4517.sendpatchset@localhost.localdomain>
References: <20080401054324.829.4517.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080401060330.743815A02@siro.lan>
Date: Tue,  1 Apr 2008 15:03:30 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: menage@google.com, xemul@openvz.org, hugh@veritas.com, skumar@linux.vnet.ibm.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> This patch removes the mem_cgroup member from mm_struct and instead adds
> an owner. This approach was suggested by Paul Menage. The advantage of
> this approach is that, once the mm->owner is known, using the subsystem
> id, the cgroup can be determined. It also allows several control groups
> that are virtually grouped by mm_struct, to exist independent of the memory
> controller i.e., without adding mem_cgroup's for each controller,
> to mm_struct.
> 
> A new config option CONFIG_MM_OWNER is added and the memory resource
> controller selects this config option.
> 
> NOTE: This patch was developed on top of 2.6.25-rc5-mm1 and is applied on top
> of the memory-controller-move-to-own-slab patch (which is already present
> in the Andrew's patchset).
> 
> I am indebted to Paul Menage for the several reviews of this patchset
> and helping me make it lighter and simpler.
> 
> This patch was tested on a powerpc box, by running a task under the memory
> resource controller and moving it across groups at a constant interval.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---

changing mm->owner without notifying controllers makes it difficult to use.
can you provide a notification mechanism?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
