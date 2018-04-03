Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2056B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 15:39:31 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m3so14134873qtb.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 12:39:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s3si3886012qkb.65.2018.04.03.12.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 12:39:30 -0700 (PDT)
Date: Tue, 3 Apr 2018 15:39:27 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v9 15/24] mm: Introduce __vm_normal_page()
Message-ID: <20180403193927.GD5935@redhat.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-16-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1520963994-28477-16-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, Mar 13, 2018 at 06:59:45PM +0100, Laurent Dufour wrote:
> When dealing with the speculative fault path we should use the VMA's field
> cached value stored in the vm_fault structure.
> 
> Currently vm_normal_page() is using the pointer to the VMA to fetch the
> vm_flags value. This patch provides a new __vm_normal_page() which is
> receiving the vm_flags flags value as parameter.
> 
> Note: The speculative path is turned on for architecture providing support
> for special PTE flag. So only the first block of vm_normal_page is used
> during the speculative path.

Might be a good idea to explicitly have SPECULATIVE Kconfig option depends
on ARCH_PTE_SPECIAL and a comment for !HAVE_PTE_SPECIAL in the function
explaining that speculative page fault should never reach that point.

Cheers,
Jerome
