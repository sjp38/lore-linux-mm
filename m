Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEC346B0038
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 19:39:30 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 201so542867175pfw.5
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 16:39:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d20si17502408plj.252.2017.01.31.16.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 16:39:29 -0800 (PST)
Date: Tue, 31 Jan 2017 16:39:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/5] userfaultfd: non-cooperative: add event for
 memory unmaps
Message-Id: <20170131163928.4e4e05fbd93358d9b937d79b@linux-foundation.org>
In-Reply-To: <1485542673-24387-3-git-send-email-rppt@linux.vnet.ibm.com>
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1485542673-24387-3-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 27 Jan 2017 20:44:30 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> When a non-cooperative userfaultfd monitor copies pages in the background,
> it may encounter regions that were already unmapped. Addition of
> UFFD_EVENT_UNMAP allows the uffd monitor to track precisely changes in the
> virtual memory layout.
> 
> Since there might be different uffd contexts for the affected VMAs, we
> first should create a temporary representation for the unmap event for each
> uffd context and then notify them one by one to the appropriate userfault
> file descriptors.
> 
> The event notification occurs after the mmap_sem has been released.

I was going to bug you about not updating
Documentation/vm/userfaultfd.txt but the UFFD_FEATURE flags aren't
documented?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
