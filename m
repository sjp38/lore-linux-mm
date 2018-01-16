Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 478096B0268
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 10:11:48 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w103so10951809wrb.2
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 07:11:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f55sor1549296ede.35.2018.01.16.07.11.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 07:11:47 -0800 (PST)
Date: Tue, 16 Jan 2018 18:11:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v6 00/24] Speculative page faults
Message-ID: <20180116151145.74odvlj6mjuwq3rr@node.shutemov.name>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Fri, Jan 12, 2018 at 06:25:44PM +0100, Laurent Dufour wrote:
> ------------------
> Benchmarks results
> 
> Base kernel is 4.15-rc6-mmotm-2018-01-04-16-19
> SPF is BASE + this series

Do you have THP=always here? Lack of THP support worries me.

What is performance in the worst case scenario? Like when we go far enough into
speculative code path on every page fault and then fallback to normal page
fault?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
