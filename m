Message-ID: <47E369D8.2010904@cosmosbay.com>
Date: Fri, 21 Mar 2008 08:55:04 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [03/14] vmallocinfo: Support display of vcompound for a virtual
 compound page
References: <20080321061703.921169367@sgi.com> <20080321061724.795229401@sgi.com>
In-Reply-To: <20080321061724.795229401@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter a ecrit :
> Add another flag to the vmalloc subsystem to mark virtual compound pages.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/vmalloc.h |    1 +
>  mm/vmalloc.c            |    3 +++
>  2 files changed, 4 insertions(+)
> 
> Index: linux-2.6.25-rc5-mm1/include/linux/vmalloc.h
> ===================================================================
> --- linux-2.6.25-rc5-mm1.orig/include/linux/vmalloc.h	2008-03-19 18:17:42.093443900 -0700
> +++ linux-2.6.25-rc5-mm1/include/linux/vmalloc.h	2008-03-19 18:27:20.150422445 -0700
> @@ -12,6 +12,7 @@ struct vm_area_struct;
>  #define VM_MAP		0x00000004	/* vmap()ed pages */
>  #define VM_USERMAP	0x00000008	/* suitable for remap_vmalloc_range */
>  #define VM_VPAGES	0x00000010	/* buffer for pages was vmalloc'ed */
> +#define VM_VCOMPOUND	0x00000020	/* Page allocator fallback */
>  /* bits [20..32] reserved for arch specific ioremap internals */
>  
>  /*
> Index: linux-2.6.25-rc5-mm1/mm/vmalloc.c
> ===================================================================
> --- linux-2.6.25-rc5-mm1.orig/mm/vmalloc.c	2008-03-19 18:18:02.689633934 -0700
> +++ linux-2.6.25-rc5-mm1/mm/vmalloc.c	2008-03-19 18:27:20.150422445 -0700
> @@ -974,6 +974,9 @@ static int s_show(struct seq_file *m, vo
>  	if (v->flags & VM_VPAGES)
>  		seq_printf(m, " vpages");
>  
> +	if (v->flags & VM_VCOMPOUND)
> +		seq_printf(m, " vcompound");
> +
>  	seq_putc(m, '\n');
>  	return 0;
>  }
> 

I would love to see NUMA information as well on vmallocinfo, but have 
currently no available time to prepare a patch.

Counters with numbers of pages per node would be great.

(like in /proc/pid/numa_maps)

N0=2 N1=2 N2=2 N3=2


This way we could check hashdist is working or not, since it depends on 
various numa policies :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
