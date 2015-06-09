Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDB36B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 16:29:11 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so21746990pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 13:29:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tv5si10277921pbc.226.2015.06.09.13.29.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 13:29:09 -0700 (PDT)
Date: Tue, 9 Jun 2015 13:29:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memory hotplug: print the last vmemmap region at the
 end of hot add memory
Message-Id: <20150609132908.c5a9d2c9714bd7a8f33ffde8@linux-foundation.org>
In-Reply-To: <55766068.9090809@cn.fujitsu.com>
References: <1433745881-7179-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
	<20150608163053.c481d9a5057513130f760910@linux-foundation.org>
	<55766068.9090809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, vbabka@suse.cz, rientjes@google.com, n-horiguchi@ah.jp.nec.com, zhenzhang.zhang@huawei.com, wangnan0@huawei.com, fabf@skynet.be

On Tue, 9 Jun 2015 11:41:28 +0800 Zhu Guihua <zhugh.fnst@cn.fujitsu.com> wrote:

> >> --- a/mm/memory_hotplug.c
> >> +++ b/mm/memory_hotplug.c
> >> @@ -513,6 +513,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
> >>   			break;
> >>   		err = 0;
> >>   	}
> >> +	vmemmap_populate_print_last();
> >>   
> >>   	return err;
> >>   }
> > vmemmap_populate_print_last() is only available on x86_64, when
> > CONFIG_SPARSEMEM_VMEMMAP=y.  Are you sure this won't break builds?
> 
> I tried this on i386 and on x86_64 when CONFIG_SPARSEMEM_VMEMMAP=n ,
> it builds ok.

With powerpc:

akpm3:/usr/src/25> make allmodconfig
akpm3:/usr/src/25> make mm/memory_hotplug.o
akpm3:/usr/src/25> nm mm/memory_hotplug.o | grep vmemmap_populate_print_last
	U .vmemmap_populate_print_last
akpm3:/usr/src/25> grep -r vmemmap_populate_print_last arch/powerpc
akpm3:/usr/src/25> 

So I think that's going to break.

I expect ia64 will break also, but I didn't investigate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
