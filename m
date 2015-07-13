Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 881716B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 13:07:00 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so35068241pac.3
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 10:07:00 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id bh8si29460234pdb.2.2015.07.13.10.06.59
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 10:06:59 -0700 (PDT)
Message-ID: <55A3EFE9.7080101@linux.intel.com>
Date: Mon, 13 Jul 2015 10:05:45 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] x86, mpx: do not set ->vm_ops on mpx VMAs
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com> <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com> <20150713165323.GA7906@redhat.com>
In-Reply-To: <20150713165323.GA7906@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

On 07/13/2015 09:53 AM, Oleg Nesterov wrote:
> On 07/13, Kirill A. Shutemov wrote:
>>
>> We don't really need ->vm_ops here: MPX VMA can be detected with VM_MPX
>> flag. And vma_merge() will not merge MPX VMA with non-MPX VMA, because
>> ->vm_flags won't match.
> 
> Agreed.
> 
> I am wondering if something like the patch below (on top of yours) makes
> sense... Not sure, but mpx_mmap() doesn't look nice too, and with this
> change we can unexport mmap_region().

These both look nice to me (and they both cull specialty MPX code which
is excellent).  I'll run them through a quick test.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
