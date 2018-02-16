Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7866B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 04:13:10 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k38so1254671wre.23
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 01:13:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 15sor4117162wmu.78.2018.02.16.01.13.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 01:13:08 -0800 (PST)
Date: Fri, 16 Feb 2018 10:13:04 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [v4 4/6] mm/memory_hotplug: optimize probe routine
Message-ID: <20180216091304.hgp5tn25nleuy4jc@gmail.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-5-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215165920.8570-5-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com


* Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> When memory is hotplugged pages_correctly_reserved() is called to verify
> that the added memory is present, this routine traverses through every
> struct page and verifies that PageReserved() is set. This is a slow
> operation especially if a large amount of memory is added.
> 
> Instead of checking every page, it is enough to simply check that the
> section is present, has mapping (struct page array is allocated), and the
> mapping is online.
> 
> In addition, we should not excpect that probe routine sets flags in struct
> page, as the struct pages have not yet been initialized. The initialization
> should be done in __init_single_page(), the same as during boot.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
