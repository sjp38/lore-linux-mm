Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1356B0766
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 21:11:42 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id f22so7698022qkm.11
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 18:11:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11sor10251452qtc.35.2018.11.09.18.11.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 18:11:10 -0800 (PST)
Date: Fri, 9 Nov 2018 21:11:05 -0500
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [mm PATCH v5 6/7] mm: Add reserved flag setting to set_page_links
Message-ID: <20181110021105.ln7geexvln5ap5fg@xakep.localdomain>
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
 <154145279604.30046.5646399488589213615.stgit@ahduyck-desk1.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154145279604.30046.5646399488589213615.stgit@ahduyck-desk1.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On 18-11-05 13:19:56, Alexander Duyck wrote:
> This patch modifies the set_page_links function to include the setting of
> the reserved flag via a simple AND and OR operation. The motivation for
> this is the fact that the existing __set_bit call still seems to have
> effects on performance as replacing the call with the AND and OR can reduce
> initialization time.
> 
> Looking over the assembly code before and after the change the main
> difference between the two is that the reserved bit is stored in a value
> that is generated outside of the main initialization loop and is then
> written with the other flags field values in one write to the page->flags
> value. Previously the generated value was written and then then a btsq
> instruction was issued.
> 
> On my x86_64 test system with 3TB of persistent memory per node I saw the
> persistent memory initialization time on average drop from 23.49s to
> 19.12s per node.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
