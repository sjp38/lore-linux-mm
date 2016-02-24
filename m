Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 426F36B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 11:17:13 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id c10so15787657pfc.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 08:17:13 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id hg4si5749812pac.180.2016.02.24.08.17.12
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 08:17:12 -0800 (PST)
Date: Wed, 24 Feb 2016 16:17:12 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] thp: call pmdp_invalidate() with correct virtual address
Message-ID: <20160224161711.GA12471@arm.com>
References: <1456329483-4220-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456329483-4220-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 24, 2016 at 06:58:03PM +0300, Kirill A. Shutemov wrote:
> Sebastian Ott and Gerald Schaefer reported random crashes on s390.
> It was bisected to my THP refcounting patchset.
> 
> The problem is that pmdp_invalidated() called with wrong virtual
> address. It got offset up by HPAGE_PMD_SIZE by loop over ptes.
> 
> The solution is to introduce new variable to be used in loop and don't
> touch 'haddr'.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Reported-by Sebastian Ott <sebott@linux.vnet.ibm.com>
> ---
>  mm/huge_memory.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)

Looks good to me:

Reviewed-by: Will Deacon <will.deacon@arm.com>

Thanks,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
