Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D562E831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 04:12:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r203so24029681wmb.2
        for <linux-mm@kvack.org>; Mon, 22 May 2017 01:12:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k48si12631112wrk.201.2017.05.22.01.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 01:12:35 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4M83idu047330
	for <linux-mm@kvack.org>; Mon, 22 May 2017 04:12:34 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2aksr8nn9h-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 May 2017 04:12:34 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 22 May 2017 09:12:31 +0100
Date: Mon, 22 May 2017 11:12:25 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
 <8b21bb9a-4efc-288b-933d-be7e6a5e4a0a@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b21bb9a-4efc-288b-933d-be7e6a5e4a0a@linux.vnet.ibm.com>
Message-Id: <20170522081223.GD27382@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Mon, May 22, 2017 at 12:56:45PM +0530, Anshuman Khandual wrote:
> On 05/22/2017 11:42 AM, Mike Rapoport wrote:
> > Currently applications can explicitly enable or disable THP for a memory
> > region using MADV_HUGEPAGE or MADV_NOHUGEPAGE. However, once either of
> > these advises is used, the region will always have
> > VM_HUGEPAGE/VM_NOHUGEPAGE flag set in vma->vm_flags.
> > The MADV_CLR_HUGEPAGE resets both these flags and allows managing THP in
> > the region according to system-wide settings.
> 
> Invoking madvise() for the first time with either MADV_HUGEPAGE or
> MADV_NOHUGEPAGE on the buffer will unsubscribe it from the system
> wide behavior for good. I am not saying we should not have a way
> to put it back into system wide mode but are there no other functions
> through madvise() or any other interface which may have the same
> situation.

There are madvise() interfaces that set or clear some of the vma->vm_flags,
e.g MADV_*FORK or MADV_*DUMP. The difference with MADV_*HUGEPAGE is that
it is using two flags and with current madvise() interface either of them
has to be set, but there is no interface to clear them both.

--
Sincerely yours,
Mike. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
