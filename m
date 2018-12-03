Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 631F06B689D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 05:33:28 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so12566773qka.7
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 02:33:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l90si4131613qte.331.2018.12.03.02.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 02:33:27 -0800 (PST)
Subject: Re: [PATCH RFCv2 2/4] mm/memory_hotplug: Replace "bool want_memblock"
 by "int type"
References: <20181130175922.10425-1-david@redhat.com>
 <20181130175922.10425-3-david@redhat.com>
 <20181201015024.3o334nk2fe5mlasj@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <5ecbff41-fc41-79fc-696e-4ca1f066f9aa@redhat.com>
Date: Mon, 3 Dec 2018 11:33:12 +0100
MIME-Version: 1.0
In-Reply-To: <20181201015024.3o334nk2fe5mlasj@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oscar Salvador <osalvador@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Christophe Leroy <christophe.leroy@c-s.fr>, Jonathan Neusch??fer <j.neuschaefer@gmx.net>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Arun KS <arunks@codeaurora.org>, Rob Herring <robh@kernel.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Logan Gunthorpe <logang@deltatee.com>, J??r??me Glisse <jglisse@redhat.com>, "Jan H. Sch??nherr" <jschoenh@amazon.de>, Dave Jiang <dave.jiang@intel.com>, Matthew Wilcox <willy@infradead.org>, Mathieu Malaterre <malat@debian.org>

On 01.12.18 02:50, Wei Yang wrote:
> On Fri, Nov 30, 2018 at 06:59:20PM +0100, David Hildenbrand wrote:
>> Let's pass a memory block type instead. Pass "MEMORY_BLOCK_NONE" for device
>> memory and for now "MEMORY_BLOCK_UNSPECIFIED" for anything else. No
>> functional change.
> 
> I would suggest to put more words to this.

Sure, makes sense, I'll add more details. Thanks!

> 
> "
> Function arch_add_memory()'s last parameter *want_memblock* is used to
> determin whether it is necessary to create a corresponding memory block
> device. After introducing the memory block type, this patch replaces the
> bool type *want_memblock* with memory block type with following rules
> for now:
> 
>   * Pass "MEMORY_BLOCK_NONE" for device memory
>   * Pass "MEMORY_BLOCK_UNSPECIFIED" for anything else 
> 
> Since this parameter is passed deep to __add_section(), all its
> descendents are effected. Below lists those descendents.
> 
>   arch_add_memory()
>     add_pages()
>       __add_pages()
>         __add_section()
> 
> "

[...]


-- 

Thanks,

David / dhildenb
