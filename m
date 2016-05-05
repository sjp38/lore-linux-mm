Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2656B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 05:54:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so10590265wme.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 02:54:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kn5si10469600wjc.117.2016.05.05.02.53.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 May 2016 02:53:59 -0700 (PDT)
Date: Thu, 5 May 2016 10:53:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/numa/thp: fix assumptions of
 migrate_misplaced_transhuge_page()
Message-ID: <20160505095356.GD2765@suse.de>
References: <1462278831-1959-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1462278831-1959-1-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, May 03, 2016 at 02:33:51PM +0200, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> Fix assumptions in migrate_misplaced_transhuge_page() which is only
> call by do_huge_pmd_numa_page() itself only call by __handle_mm_fault()
> for pmd with PROT_NONE. This means that if the pmd stays the same
> then there can be no concurrent get_user_pages / get_user_pages_fast
> (GUP/GUP_fast). More over because migrate_misplaced_transhuge_page()
> abort if page is mapped more than once then there can be no GUP from
> a different process. Finaly, holding the pmd lock assure us that no
> other part of the kernel can take an extra reference on the page.
> 
> In the end this means that the failure code path should never be
> taken unless something is horribly wrong, so convert it to BUG_ON().
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
