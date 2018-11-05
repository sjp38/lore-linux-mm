Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E78036B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 05:42:10 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id s23-v6so9606407plq.7
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 02:42:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21-v6sor40641974pgb.24.2018.11.05.02.42.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 02:42:09 -0800 (PST)
Date: Mon, 5 Nov 2018 21:42:04 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v11 00/26] Speculative page faults
Message-ID: <20181105104204.GB9042@350D>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Thu, May 17, 2018 at 01:06:07PM +0200, Laurent Dufour wrote:
> This is a port on kernel 4.17 of the work done by Peter Zijlstra to handle
> page fault without holding the mm semaphore [1].
> 
> The idea is to try to handle user space page faults without holding the
> mmap_sem. This should allow better concurrency for massively threaded

Question -- I presume mmap_sem (rw_semaphore implementation tested against)
was qrwlock?

Balbir Singh.
