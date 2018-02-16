Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 217286B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 04:23:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id f3so616753wmc.8
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 01:23:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v190sor3772502wme.91.2018.02.16.01.23.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 01:23:33 -0800 (PST)
Date: Fri, 16 Feb 2018 10:23:30 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [v4 3/6] mm: uninitialized struct page poisoning sanity checking
Message-ID: <20180216092330.k7hutkvjmy7nope3@gmail.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-4-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215165920.8570-4-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com


* Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> During boot we poison struct page memory in order to ensure that no one is
> accessing this memory until the struct pages are initialized in
> __init_single_page().
> 
> This patch adds more scrutiny to this checking by making sure that flags
> do not equal the poison pattern when they are accessed.  The pattern is all
> ones.
> 
> Since node id is also stored in struct page, and may be accessed quite
> early, we add this enforcement into page_to_nid() function as well.
> Note, this is applicable only when NODE_NOT_IN_PAGE_FLAGS=n
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Ingo Molnar <mingo@kernel.org>
> Acked-by: Michal Hocko <mhocko@suse.com>

Please always start patch titles with a verb, i.e.:

 mm: Add uninitialized struct page poisoning sanity check

or so.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
