Date: Tue, 15 Apr 2008 12:16:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] use vmalloc for mem_cgroup allocation. v2
Message-Id: <20080415121617.16127623.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080414191730.7d13e619.akpm@linux-foundation.org>
References: <20080415105434.3044afb6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080415111038.ffac0e12.kamezawa.hiroyu@jp.fujitsu.com>
	<20080414191730.7d13e619.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, lizf@cn.fujitsu.com, menage@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Apr 2008 19:17:30 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> Well...  vmalloced memory is of course a little slower to use - additional
> TLB pressure.
> 
> Do you think the memcgroup is accessed frequently enough to use vmalloc()
> only on those architectures which actually need it?
> 
> Because it'd be pretty simple to implement:
> 
> 	if (sizeof(struct mem_group) > PAGE_SIZE)
> 		vmalloc()
> 	else
> 		kmalloc()
> 
> 	...
> 
> 	if (sizeof(struct mem_group) > PAGE_SIZE)
> 		vfree()
> 	else
> 		kfree()
> 
> the compiler will optimise away the `if'.
> 

Hmm, ok. I'll rewrite one to do that.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
