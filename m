Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3DF6B0069
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 10:16:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g10so8608354wrg.2
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 07:16:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y16sor6666100edc.22.2017.10.04.07.16.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 07:16:22 -0700 (PDT)
Date: Wed, 4 Oct 2017 17:16:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3] mm: Account pud page tables
Message-ID: <20171004141620.37qojkpftpmpgmxj@node.shutemov.name>
References: <20171002080427.3320-1-kirill.shutemov@linux.intel.com>
 <20171004134853.k2f4bah7csh6qebm@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171004134853.k2f4bah7csh6qebm@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, Oct 04, 2017 at 03:48:53PM +0200, Michal Hocko wrote:
> On Mon 02-10-17 11:04:27, Kirill A. Shutemov wrote:
> > On machine with 5-level paging support a process can allocate
> > significant amount of memory and stay unnoticed by oom-killer and
> > memory cgroup. The trick is to allocate a lot of PUD page tables.
> > We don't account PUD page tables, only PMD and PTE.
> > 
> > We already addressed the same issue for PMD page tables, see
> > dc6c9a35b66b ("mm: account pmd page tables to the process").
> > Introduction 5-level paging bring the same issue for PUD page tables.
> > 
> > The patch expands accounting to PUD level.
> 
> Can we skip the VmPUD part and reporting puds in the oom report please?
> I would like to consolidate all levels into a single counter and carying
> about one less user visible change will make it slightly easier. Or does
> anybody need this exported to the userspace?

Let me do this as a separate patch. I will also fold VmPMD into VmPTE.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
