Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 193966B0069
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 06:10:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y44so3487866wry.3
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 03:10:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor10282095edk.44.2017.10.05.03.10.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 03:10:50 -0700 (PDT)
Date: Thu, 5 Oct 2017 13:10:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm: Consolidate page table accounting
Message-ID: <20171005101048.qa62lqk6gjfz6azt@node.shutemov.name>
References: <20171004163648.11234-1-kirill.shutemov@linux.intel.com>
 <20171004163648.11234-2-kirill.shutemov@linux.intel.com>
 <3aabab03-7f0a-e82e-a1c2-79120aed5ace@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3aabab03-7f0a-e82e-a1c2-79120aed5ace@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On Thu, Oct 05, 2017 at 10:38:29AM +0530, Anshuman Khandual wrote:
> On 10/04/2017 10:06 PM, Kirill A. Shutemov wrote:
> > This patch switches page table accounting to single counter from
> > three -- nr_ptes, nr_pmds and nr_puds.
> > 
> > mm->pgtables_bytes is now used to account page table levels. We use
> > bytes, because page table size for different levels of page table tree
> > may be different.
> > 
> > The change has user-visible effect: we don't have VmPMD and VmPUD
> > reported in /proc/[pid]/status. Not sure if anybody uses them.
> > (As alternative, we can always report 0 kB for them.)
> > 
> > OOM-killer report is also slightly changed: we now report pgtables_bytes
> > instead of nr_ptes, nr_pmd, nr_puds.
> 
> Could you please mention the motivation of doing this ? Why we are
> consolidating the counters which also changes /proc/ interface as
> well as OOM report ? What is the benefit ?

Sure, I'll update description.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
