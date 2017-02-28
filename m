Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9BD56B0387
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:55:52 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n186so20827129qkb.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:55:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k1si1750816qtk.215.2017.02.28.07.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 07:55:52 -0800 (PST)
Date: Tue, 28 Feb 2017 16:55:49 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: fault in __do_fault
Message-ID: <20170228155549.GJ5816@redhat.com>
References: <CACT4Y+YgntApw9WMLZwF_ncF4JQdA2FNHDpzM+8hb_FpCuuC_g@mail.gmail.com>
 <20170228153220.GA30524@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228153220.GA30524@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, syzkaller <syzkaller@googlegroups.com>

On Tue, Feb 28, 2017 at 06:32:20PM +0300, Kirill A. Shutemov wrote:
> Andrea, does it look okay for you?
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 625b7285a37b..56f61f1a1dc1 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -489,7 +489,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
>                          * in such case.
>                          */
>                         down_read(&mm->mmap_sem);
> -                       ret = 0;
> +                       ret = VM_FAULT_NOPAGE;
>                 }
>         }

Yes, I did the same fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
