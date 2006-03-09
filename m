Date: Thu, 9 Mar 2006 04:01:09 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH: 013/017](RFC) Memory hotplug for new nodes v.3.
 (changes from __init to __meminit)
Message-Id: <20060309040109.4f9c7d5c.akpm@osdl.org>
In-Reply-To: <20060308213446.003C.Y-GOTO@jp.fujitsu.com>
References: <20060308213446.003C.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
> Index: pgdat6/include/linux/bootmem.h
>  ===================================================================
>  --- pgdat6.orig/include/linux/bootmem.h	2006-03-06 18:25:37.000000000 +0900
>  +++ pgdat6/include/linux/bootmem.h	2006-03-06 21:08:05.000000000 +0900
>  @@ -88,8 +88,8 @@ static inline void *alloc_remap(int nid,
>   }
>   #endif
>   
>  -extern unsigned long __initdata nr_kernel_pages;
>  -extern unsigned long __initdata nr_all_pages;
>  +extern unsigned long __meminitdata nr_kernel_pages;
>  +extern unsigned long __meminitdata nr_all_pages;

Declaring the section for externs like this isn't very useful really.  I
don't think there's any way in which the compiler can check it and the
linker will look at the definition, not at the declarations.  And if we add
these, we just need to keep the declarations updated for cosmetic reasons
as you've discovered.

So I'd recommend you simply remove the __initdata tags here and leave it at
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
