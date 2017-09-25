Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B2FB36B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 09:07:19 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r74so8552294wme.5
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 06:07:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z13sor3177705edl.16.2017.09.25.06.07.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 06:07:18 -0700 (PDT)
Date: Mon, 25 Sep 2017 16:07:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2] mm: Account pud page tables
Message-ID: <20170925130715.kebf5e3xjctpcalp@node.shutemov.name>
References: <20170925073913.22628-1-kirill.shutemov@linux.intel.com>
 <20170925115430.zccesf75c4ysaznb@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925115430.zccesf75c4ysaznb@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Mon, Sep 25, 2017 at 01:54:30PM +0200, Michal Hocko wrote:
> On Mon 25-09-17 10:39:13, Kirill A. Shutemov wrote:
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
> OK, we definitely need this or something like that but I really do not
> like how much code we actually need for each pte level for accounting.
> Do we really need to distinguish each level? Do we have any arch that
> would use a different number of pages to back pte/pmd/pud?

Looks like we actually do. At least on mips. See PMD_ORDER/PUD_ORDER.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
