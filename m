Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id F05166B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 15:43:30 -0500 (EST)
Received: by ioc74 with SMTP id 74so45303732ioc.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 12:43:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f126si13536875ioe.64.2015.11.11.12.42.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 12:42:37 -0800 (PST)
Date: Wed, 11 Nov 2015 21:42:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
Message-ID: <20151111204234.GI4573@redhat.com>
References: <1447256116-16461-1-git-send-email-jjherne@linux.vnet.ibm.com>
 <20151111173044.GF4573@redhat.com>
 <56439B56.1090105@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56439B56.1090105@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, KVM list <kvm@vger.kernel.org>

On Wed, Nov 11, 2015 at 08:47:34PM +0100, Christian Borntraeger wrote:
> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Who is going to take this patch? If I should take the patch, I need an
> ACK from the memory mgmt folks.

I would suggest to resend in CC to Andrew to merge in -mm after taking
care of the below, as it's a mm common code part.

> 
> Christian
> 
> 
> >> ---
> >>  mm/huge_memory.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> >> index c29ddeb..a8b5347 100644
> >> --- a/mm/huge_memory.c
> >> +++ b/mm/huge_memory.c
> >> @@ -2025,7 +2025,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
> >>  		/*
> >>  		 * Be somewhat over-protective like KSM for now!
> >>  		 */
> >> -		if (*vm_flags & (VM_NOHUGEPAGE | VM_NO_THP))
> >> +		if (*vm_flags & VM_NO_THP)
> >>  			return -EINVAL;
> >>  		*vm_flags &= ~VM_HUGEPAGE;
> >>  		*vm_flags |= VM_NOHUGEPAGE;

If we make this change the MADV_HUGEPAGE must be taken care of too or
it doesn't make sense to threat them differently.

After taking care of the MADV_HUGEPAGE you can add my reviewed-by when
you resubmit to Andrew.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
