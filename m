Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 674766B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 03:50:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q24-v6so591051wmq.9
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:50:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l14-v6sor243685wrw.79.2018.07.26.00.50.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 00:50:41 -0700 (PDT)
Date: Thu, 26 Jul 2018 09:50:40 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 1/3] mm: make memmap_init a proper function
Message-ID: <20180726075040.GB22028@techadventures.net>
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
 <20180724235520.10200-2-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724235520.10200-2-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Tue, Jul 24, 2018 at 07:55:18PM -0400, Pavel Tatashin wrote:
> memmap_init is sometimes a macro sometimes a function based on
> __HAVE_ARCH_MEMMAP_INIT. It is only a function on ia64. Make
> memmap_init a weak function instead, and let ia64 redefine it.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Looks good, and it is easier to read.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks
-- 
Oscar Salvador
SUSE L3
