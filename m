Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 96C966B0036
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 17:28:19 -0400 (EDT)
Message-ID: <523776D4.4070402@jp.fujitsu.com>
Date: Mon, 16 Sep 2013 17:23:32 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v5 3/4] mm/vmalloc: revert "mm/vmalloc.c: check
 VM_UNINITIALIZED flag in s_show instead of show_numa_info"
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com> <1379202342-23140-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379202342-23140-3-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: liwanp@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/14/2013 7:45 PM, Wanpeng Li wrote:
> Changelog:
>  *v2 -> v3: revert commit d157a558 directly
> 
> The VM_UNINITIALIZED/VM_UNLIST flag introduced by commit f5252e00(mm: avoid
> null pointer access in vm_struct via /proc/vmallocinfo) is used to avoid
> accessing the pages field with unallocated page when show_numa_info() is
> called. This patch move the check just before show_numa_info in order that
> some messages still can be dumped via /proc/vmallocinfo. This patch revert 
> commit d157a558 (mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead 
> of show_numa_info);

Both d157a558 and your patch don't explain why your one is better. Yes, some
messages _can_ be dumped. But why should we do so?

And No. __get_vm_area_node() doesn't use __GFP_ZERO for allocating vm_area_struct.
dumped partial dump is not only partial, but also may be garbage.

I wonder why we need to call setup_vmalloc_vm() _after_ insert_vmap_area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
