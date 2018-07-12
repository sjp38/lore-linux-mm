Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4BC6B0269
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 11:08:07 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e93-v6so15335046plb.5
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 08:08:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y89-v6sor2523625pfk.78.2018.07.12.08.08.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 08:08:06 -0700 (PDT)
Date: Thu, 12 Jul 2018 18:08:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 0/2] Fix crash due to vma_is_anonymous() false-positives
Message-ID: <20180712150759.acjj4jdw4ykwvzwg@kshutemo-mobl1>
References: <20180712145626.41665-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712145626.41665-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 12, 2018 at 05:56:24PM +0300, Kirill A. Shutemov wrote:
> 
> Fix crash found by syzkaller.
> 
> The fix allows to remove ->vm_ops checks.
> 
> v2:
>  - Catch few more cases where we need to initialize ->vm_ops:
>    + nommu;
>    + ia64;
>  - Make sure that we initialize ->vm_ops even if ->mmap failed.
>    We need ->vm_ops in error path too.

Just to be clear: it *should* help found issues, but I don't have setup to
test nommu changes.

And ion-related bug was actually caused by fault injection that failed
page allocation and ->mmap not setting ->vm_ops. It should be fine now.
But again I wasn't able to trigger the exact situation.

-- 
 Kirill A. Shutemov
