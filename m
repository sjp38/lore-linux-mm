Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8C996B0633
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 17:29:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h126so346958wmf.10
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 14:29:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n10si209767wra.23.2017.08.02.14.29.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 14:29:27 -0700 (PDT)
Date: Wed, 2 Aug 2017 14:29:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/6] userfaultfd updates for v4.13-rc3
Message-Id: <20170802142925.4a3ad06ff7b0e769046f52db@linux-foundation.org>
In-Reply-To: <20170802165145.22628-1-aarcange@redhat.com>
References: <20170802165145.22628-1-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Maxime Coquelin <maxime.coquelin@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Alexey Perevalov <a.perevalov@samsung.com>

On Wed,  2 Aug 2017 18:51:39 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:

> Hello,
> 
> these are some uffd updates I have pending that looks ready for
> merging. vhost-user KVM developement run into a crash so patch 1/6 is
> urgent (and simple), the rest is not urgent.
> 
> The testcase has been updated to exercise it.
> 
> This should apply clean to -mm, and I reviewed in detail all other
> userfaultfd patches that are in -mm and they're all great, including
> the shmem zeropage addition.
> 
> Alexey Perevalov (1):
>   userfaultfd: provide pid in userfault msg
> 
> Andrea Arcangeli (5):
>   userfaultfd: hugetlbfs: remove superfluous page unlock in VM_SHARED
>     case
>   userfaultfd: selftest: exercise UFFDIO_COPY/ZEROPAGE -EEXIST
>   userfaultfd: selftest: explicit failure if the SIGBUS test failed
>   userfaultfd: call userfaultfd_unmap_prep only if __split_vma succeeds
>   userfaultfd: provide pid in userfault msg - add feat union

I'm thinking "userfaultfd: hugetlbfs: remove superfluous page unlock in
VM_SHARED case" goes into 4.13-rc and the other patches into 4.14-rc1. 
Sound sane?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
