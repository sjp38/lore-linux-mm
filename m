Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7ABD96B032D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 07:05:38 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so42590016pdr.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 04:05:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id hc9si12430554pac.157.2015.07.16.04.05.37
        for <linux-mm@kvack.org>;
        Thu, 16 Jul 2015 04:05:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <55A3EFE9.7080101@linux.intel.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20150713165323.GA7906@redhat.com>
 <55A3EFE9.7080101@linux.intel.com>
Subject: Re: [PATCH 2/5] x86, mpx: do not set ->vm_ops on mpx VMAs
Content-Transfer-Encoding: 7bit
Message-Id: <20150716110503.9A4F5196@black.fi.intel.com>
Date: Thu, 16 Jul 2015 14:05:03 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

Dave Hansen wrote:
> On 07/13/2015 09:53 AM, Oleg Nesterov wrote:
> > On 07/13, Kirill A. Shutemov wrote:
> >>
> >> We don't really need ->vm_ops here: MPX VMA can be detected with VM_MPX
> >> flag. And vma_merge() will not merge MPX VMA with non-MPX VMA, because
> >> ->vm_flags won't match.
> > 
> > Agreed.
> > 
> > I am wondering if something like the patch below (on top of yours) makes
> > sense... Not sure, but mpx_mmap() doesn't look nice too, and with this
> > change we can unexport mmap_region().
> 
> These both look nice to me (and they both cull specialty MPX code which
> is excellent).  I'll run them through a quick test.

Any update?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
