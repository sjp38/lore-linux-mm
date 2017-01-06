Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E7A3A6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 14:02:30 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q20so16131931ioi.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 11:02:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g140si2039246itg.69.2017.01.06.11.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 11:02:30 -0800 (PST)
Date: Fri, 6 Jan 2017 19:02:23 +0000
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH 00/42] userfaultfd tmpfs/hugetlbfs/non-cooperative v2
Message-ID: <20170106190223.GB32535@work-vm>
References: <20161216144821.5183-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Rapoport <RAPOPORT@il.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

* Andrea Arcangeli (aarcange@redhat.com) wrote:
> Hello,
> 
> these userfaultfd features are finished and are ready for larger
> exposure in -mm and upstream merging.
> 
> 1) tmpfs non present userfault
> 2) hugetlbfs non present userfault
> 3) non cooperative userfault for fork/madvise/mremap
> 
> qemu development code is already exercising 2)

I've just posted the qemu series for that to qemu-devel:

http://lists.nongnu.org/archive/html/qemu-devel/2017-01/msg00900.html

Dave
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
