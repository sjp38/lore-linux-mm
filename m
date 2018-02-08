Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1E436B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 14:13:01 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id h33so243324plh.19
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:13:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l1-v6sor199985pld.49.2018.02.08.11.13.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 11:13:00 -0800 (PST)
Date: Thu, 8 Feb 2018 11:12:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/migrate: Rename various page allocation helper
 functions
In-Reply-To: <5458c2c9-3534-c00d-7abf-3315debbf896@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1802081059190.16719@eggly.anvils>
References: <20180204065816.6885-1-khandual@linux.vnet.ibm.com> <5458c2c9-3534-c00d-7abf-3315debbf896@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.com, hughd@google.com

On Thu, 8 Feb 2018, Anshuman Khandual wrote:
> On 02/04/2018 12:28 PM, Anshuman Khandual wrote:
> > Allocation helper functions for migrate_pages() remmain scattered with
> > similar names making them really confusing. Rename these functions based
> > on type of the intended migration. Function alloc_misplaced_dst_page()
> > remains unchanged as its highly specialized. The renamed functions are
> > listed below. Functionality of migration remains unchanged.
> > 
> > 1. alloc_migrate_target -> new_page_alloc
> > 2. new_node_page -> new_page_alloc_othernode
> > 3. new_page -> new_page_alloc_keepnode
> > 4. alloc_new_node_page -> new_page_alloc_node
> > 5. new_page -> new_page_alloc_mempolicy
> 
> Hello Michal/Hugh,
> 
> Does the renaming good enough or we should just not rename these.

I'll neither ack nor nack, I don't greatly care: my concern was
to head you away from gathering them into a single header file.

Though alloc_new_node_page seems to me a *much* better name than
new_page_alloc_node; and I'm puzzled why you would demand this
conformity of some but not all of the functions of that type.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
