Date: Thu, 27 Dec 2007 16:18:09 -0800 (PST)
Message-Id: <20071227.161809.92032908.davem@davemloft.net>
Subject: Re: [PATCH 03/10] percpu: Make the asm-generic/percpu.h more
 "generic"
From: David Miller <davem@davemloft.net>
In-Reply-To: <20071228001047.292111000@sgi.com>
References: <20071228001046.854702000@sgi.com>
	<20071228001047.292111000@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: travis@sgi.com
Date: Thu, 27 Dec 2007 16:10:49 -0800
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rusty@rustcorp.com.au, ak@suse.de
List-ID: <linux-mm.kvack.org>

> V1->V2:
> - add support for PER_CPU_ATTRIBUTES
> 
> Add the ability to use generic/percpu even if the arch needs to override
> several aspects of its operations. This will enable the use of generic
> percpu.h for all arches.
> 
> An arch may define:
> 
> __per_cpu_offset	Do not use the generic pointer array. Arch must
> 			define per_cpu_offset(cpu) (used by x86_64, s390).
> 
> __my_cpu_offset		Can be defined to provide an optimized way to determine
> 			the offset for variables of the currently executing
> 			processor. Used by ia64, x86_64, x86_32, sparc64, s/390.
> 
> SHIFT_PTR(ptr, offset)	If an arch defines it then special handling
> 			of pointer arithmentic may be implemented. Used
> 			by s/390.
> 
> 
> (Some of these special percpu arch implementations may be later consolidated
> so that there are less cases to deal with.)
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Andi Kleen <ak@suse.de>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Mike Travis <travis@sgi.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
