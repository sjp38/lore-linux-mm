Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F07406B6E0F
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:45:02 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so13521194pfq.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:45:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c76si14804754pga.70.2018.12.04.01.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 01:45:01 -0800 (PST)
Date: Tue, 4 Dec 2018 10:44:54 +0100
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
Subject: Re: [PATCH RFCv2 3/4] mm/memory_hotplug: Introduce and use more
 memory types
Message-ID: <20181204104454.522a3ba2@naga.suse.cz>
In-Reply-To: <20181130175922.10425-4-david@redhat.com>
References: <20181130175922.10425-1-david@redhat.com>
	<20181130175922.10425-4-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, xen-devel@lists.xenproject.org, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Rashmica Gupta <rashmica.g@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Balbir Singh <bsingharora@gmail.com>, Michael Neuling <mikey@neuling.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, YueHaibing <yuehaibing@huawei.com>, Vasily Gorbik <gor@linux.ibm.com>, Ingo Molnar <mingo@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Oscar Salvador <osalvador@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mathieu Malaterre <malat@debian.org>, Michal Hocko <mhocko@suse.com>, Arun KS <arunks@codeaurora.org>, Andrew Banman <andrew.banman@hpe.com>, Dave Hansen <dave.hansen@linux.intel.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, 30 Nov 2018 18:59:21 +0100
David Hildenbrand <david@redhat.com> wrote:

> Let's introduce new types for different kinds of memory blocks and use
> them in existing code. As I don't see an easy way to split this up,
> do it in one hunk for now.
> 
> acpi:
>  Use DIMM or DIMM_UNREMOVABLE depending on hotremove support in the kernel.
>  Properly change the type when trying to add memory that was already
>  detected and used during boot (so this memory will correctly end up as
>  "acpi" in user space).
> 
> pseries:
>  Use DIMM or DIMM_UNREMOVABLE depending on hotremove support in the kernel.
>  As far as I see, handling like in the acpi case for existing blocks is
>  not required.
> 
> probed memory from user space:
>  Use DIMM_UNREMOVABLE as there is no interface to get rid of this code
>  again.
> 
> hv_balloon,xen/balloon:
>  Use BALLOON. As simple as that :)
> 
> s390x/sclp:
>  Use a dedicated type S390X_STANDBY as this type of memory and it's
>  semantics are very s390x specific.
> 
> powernv/memtrace:
>  Only allow to use BOOT memory for memtrace. I consider this code in
>  general dangerous, but we have to keep it working ... most probably just
>  a debug feature.

I don't think it should be arbitrarily restricted like that.

Thanks

Michal
