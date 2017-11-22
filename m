Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A61EA6B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 00:41:49 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id j12so373310qtc.20
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 21:41:49 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i193si11678155qke.20.2017.11.21.21.41.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 21:41:48 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAM5efXR131875
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 00:41:47 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ecyf08gnn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 00:41:46 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 22 Nov 2017 05:41:44 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 2/2] x86/selftests: Add test for mapping placement for 5-level paging
In-Reply-To: <20171115143607.81541-2-kirill.shutemov@linux.intel.com>
References: <20171115143607.81541-1-kirill.shutemov@linux.intel.com> <20171115143607.81541-2-kirill.shutemov@linux.intel.com>
Date: Wed, 22 Nov 2017 11:11:36 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87y3myzx7z.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> With 5-level paging, we have 56-bit virtual address space available for
> userspace. But we don't want to expose userspace to addresses above
> 47-bits, unless it asked specifically for it.
>
> We use mmap(2) hint address as a way for kernel to know if it's okay to
> allocate virtual memory above 47-bit.
>
> Let's add a self-test that covers few corner cases of the interface.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Can we move this to selftest/vm/ ? I had a variant which i was using to
test issues on ppc64. One change we did recently was to use >=128TB as
the hint addr value to select larger address space. I also would like to
check for exact mmap return addr in some case. Attaching below the test
i was using. I will check whether this patch can be updated to test what
is converted in my selftest. I also want to do the boundary check twice.
The hash trasnslation mode in POWER require us to track addr limit and
we had bugs around address space slection before and after updating the
addr limit.
