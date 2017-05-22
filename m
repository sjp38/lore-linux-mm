Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0F8831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 03:27:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d127so23702892wmf.15
        for <linux-mm@kvack.org>; Mon, 22 May 2017 00:27:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x62si32153999wmb.160.2017.05.22.00.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 00:27:44 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4M7NgX2108440
	for <linux-mm@kvack.org>; Mon, 22 May 2017 03:27:42 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2aku1y1bcd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 May 2017 03:27:42 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 22 May 2017 17:27:39 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4M7RSJC55771242
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:27:36 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4M7QvTv005238
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:26:57 +1000
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 22 May 2017 12:56:45 +0530
MIME-Version: 1.0
In-Reply-To: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <8b21bb9a-4efc-288b-933d-be7e6a5e4a0a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On 05/22/2017 11:42 AM, Mike Rapoport wrote:
> Currently applications can explicitly enable or disable THP for a memory
> region using MADV_HUGEPAGE or MADV_NOHUGEPAGE. However, once either of
> these advises is used, the region will always have
> VM_HUGEPAGE/VM_NOHUGEPAGE flag set in vma->vm_flags.
> The MADV_CLR_HUGEPAGE resets both these flags and allows managing THP in
> the region according to system-wide settings.

Invoking madvise() for the first time with either MADV_HUGEPAGE or
MADV_NOHUGEPAGE on the buffer will unsubscribe it from the system
wide behavior for good. I am not saying we should not have a way
to put it back into system wide mode but are there no other functions
through madvise() or any other interface which may have the same
situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
