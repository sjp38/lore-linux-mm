Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id E0DC86B006C
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 06:05:51 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id em10so10216576wid.13
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 03:05:51 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.226])
        by mx.google.com with ESMTP id pm1si23916092wjb.68.2014.10.08.03.05.50
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 03:05:50 -0700 (PDT)
Date: Wed, 8 Oct 2014 13:03:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/8] mm: replace remap_file_pages() syscall with emulation
Message-ID: <20141008100314.GA1795@node.dhcp.inet.fi>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1399387052-31660-2-git-send-email-kirill.shutemov@linux.intel.com>
 <5434DEBD.8040607@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5434DEBD.8040607@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

On Wed, Oct 08, 2014 at 12:20:37PM +0530, Vineet Gupta wrote:
> Hi Kirill,
> 
> Due to broken PAGE_FILE on arc, I was giving this emulation patch a try and it
> seems we need a minor fix to this patch. I know this is not slated for merge soon,
> but u can add the fix nevertheless and my Tested-by:
> 
> Problem showed up with Ingo Korb's remap-demo.c test case from [1]
> 
> [1] https://lkml.org/lkml/2014/7/14/335
> 
> > +
> > +	ret = do_mmap_pgoff(vma->vm_file, start, size,
> > +			prot, flags, pgoff, &populate);
> > +	if (populate)
> > +		mm_populate(ret, populate);
> > +out:
> > +	up_write(&mm->mmap_sem);
> 
> On success needs to return 0, not mapped addr.
> 
> 	if (!IS_ERR_VALUE(ret))
> 		ret = 0;

This bug (and few more) has been fixed long ago in -mm tree.

Thanks for testing, anyway.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
