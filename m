Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 47E136B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 05:55:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r68so1489223wmr.6
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 02:55:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b13sor781155edk.55.2017.10.06.02.55.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Oct 2017 02:55:20 -0700 (PDT)
Date: Fri, 6 Oct 2017 12:55:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/2] mm: Introduce wrappers to access mm->nr_ptes
Message-ID: <20171006095517.vkpao4iu35ocashi@node.shutemov.name>
References: <20171005101442.49555-1-kirill.shutemov@linux.intel.com>
 <856babfe-fd38-0bd2-d8d2-64dfe6672da8@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <856babfe-fd38-0bd2-d8d2-64dfe6672da8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On Fri, Oct 06, 2017 at 09:32:03AM +0530, Anshuman Khandual wrote:
> On 10/05/2017 03:44 PM, Kirill A. Shutemov wrote:
> > Let's add wrappers for ->nr_ptes with the same interface as for nr_pmd
> > and nr_pud.
> > 
> > It's preparation for consolidation of page-table counters in mm_struct.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Hey Kirill,
> 
> This patch does not apply cleanly either on mainline or on the latest
> mmotm branch mmotm-2017-10-03-17-08. Is there any other branch like
> 'linux next' you might have rebased these patches against ?

It's against mmots. There's pud page tables accounting patch we depent
onto.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
