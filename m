From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH v2 03/10] slab: move up code to get kmem_cache_node in free_block()
Date: 7 May 2014 20:44:52 -0400
Message-ID: <20140508004452.27923.qmail@ns.horizon.com>
References: <alpine.DEB.2.02.1405071502040.25024@chino.kir.corp.google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1405071502040.25024@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux@horizon.com, rientjes@google.com
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

> A function called clear_obj_pfmemalloc() doesn't indicate it's returning 
> anything, I think the vast majority of people would believe that it 
> returns void just as it does.  There's no complier generated code 
> optimization with this patch and

> I'm not sure it's even correct since 
> you're now clearing after doing recheck_pfmemalloc_active().

I thought this through before rearranging the code.
recheck_pfmemalloc_active() checks global lists, but __ac_get_obj()
is doing clear_obj_pfmemalloc on a local variable.

I think it does make sense to remove the pointless "return;" in 
set_obj_pfmemalloc(), however.  Not sure it's worth asking someone to 
merge it, though.
