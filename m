Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 654AEC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 08:52:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C01120578
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 08:52:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C01120578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACED46B0003; Fri,  6 Sep 2019 04:51:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7E5C6B0006; Fri,  6 Sep 2019 04:51:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 993F36B0007; Fri,  6 Sep 2019 04:51:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 7166F6B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 04:51:59 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0A88452D2
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:51:59 +0000 (UTC)
X-FDA: 75903878358.09.tooth02_85a4a739d1c14
X-HE-Tag: tooth02_85a4a739d1c14
X-Filterd-Recvd-Size: 20024
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:51:58 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 12D5D8535C;
	Fri,  6 Sep 2019 08:51:57 +0000 (UTC)
Received: from [10.36.117.162] (ovpn-117-162.ams2.redhat.com [10.36.117.162])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E189D5D784;
	Fri,  6 Sep 2019 08:51:50 +0000 (UTC)
Subject: Re: [PATCH v2 2/7] mm: Introduce FAULT_FLAG_DEFAULT
To: Peter Xu <peterx@redhat.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
 Jerome Glisse <jglisse@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>,
 Marty McFadden <mcfadden8@llnl.gov>, Shaohua Li <shli@fb.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 Denis Plotnikov <dplotnikov@virtuozzo.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman
 <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>,
 "Dr . David Alan Gilbert" <dgilbert@redhat.com>
References: <20190905101534.9637-1-peterx@redhat.com>
 <20190905101534.9637-3-peterx@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 xsFNBFXLn5EBEAC+zYvAFJxCBY9Tr1xZgcESmxVNI/0ffzE/ZQOiHJl6mGkmA1R7/uUpiCjJ
 dBrn+lhhOYjjNefFQou6478faXE6o2AhmebqT4KiQoUQFV4R7y1KMEKoSyy8hQaK1umALTdL
 QZLQMzNE74ap+GDK0wnacPQFpcG1AE9RMq3aeErY5tujekBS32jfC/7AnH7I0v1v1TbbK3Gp
 XNeiN4QroO+5qaSr0ID2sz5jtBLRb15RMre27E1ImpaIv2Jw8NJgW0k/D1RyKCwaTsgRdwuK
 Kx/Y91XuSBdz0uOyU/S8kM1+ag0wvsGlpBVxRR/xw/E8M7TEwuCZQArqqTCmkG6HGcXFT0V9
 PXFNNgV5jXMQRwU0O/ztJIQqsE5LsUomE//bLwzj9IVsaQpKDqW6TAPjcdBDPLHvriq7kGjt
 WhVhdl0qEYB8lkBEU7V2Yb+SYhmhpDrti9Fq1EsmhiHSkxJcGREoMK/63r9WLZYI3+4W2rAc
 UucZa4OT27U5ZISjNg3Ev0rxU5UH2/pT4wJCfxwocmqaRr6UYmrtZmND89X0KigoFD/XSeVv
 jwBRNjPAubK9/k5NoRrYqztM9W6sJqrH8+UWZ1Idd/DdmogJh0gNC0+N42Za9yBRURfIdKSb
 B3JfpUqcWwE7vUaYrHG1nw54pLUoPG6sAA7Mehl3nd4pZUALHwARAQABzSREYXZpZCBIaWxk
 ZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT7CwX4EEwECACgFAljj9eoCGwMFCQlmAYAGCwkI
 BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEE3eEPcA/4Na5IIP/3T/FIQMxIfNzZshIq687qgG
 8UbspuE/YSUDdv7r5szYTK6KPTlqN8NAcSfheywbuYD9A4ZeSBWD3/NAVUdrCaRP2IvFyELj
 xoMvfJccbq45BxzgEspg/bVahNbyuBpLBVjVWwRtFCUEXkyazksSv8pdTMAs9IucChvFmmq3
 jJ2vlaz9lYt/lxN246fIVceckPMiUveimngvXZw21VOAhfQ+/sofXF8JCFv2mFcBDoa7eYob
 s0FLpmqFaeNRHAlzMWgSsP80qx5nWWEvRLdKWi533N2vC/EyunN3HcBwVrXH4hxRBMco3jvM
 m8VKLKao9wKj82qSivUnkPIwsAGNPdFoPbgghCQiBjBe6A75Z2xHFrzo7t1jg7nQfIyNC7ez
 MZBJ59sqA9EDMEJPlLNIeJmqslXPjmMFnE7Mby/+335WJYDulsRybN+W5rLT5aMvhC6x6POK
 z55fMNKrMASCzBJum2Fwjf/VnuGRYkhKCqqZ8gJ3OvmR50tInDV2jZ1DQgc3i550T5JDpToh
 dPBxZocIhzg+MBSRDXcJmHOx/7nQm3iQ6iLuwmXsRC6f5FbFefk9EjuTKcLMvBsEx+2DEx0E
 UnmJ4hVg7u1PQ+2Oy+Lh/opK/BDiqlQ8Pz2jiXv5xkECvr/3Sv59hlOCZMOaiLTTjtOIU7Tq
 7ut6OL64oAq+zsFNBFXLn5EBEADn1959INH2cwYJv0tsxf5MUCghCj/CA/lc/LMthqQ773ga
 uB9mN+F1rE9cyyXb6jyOGn+GUjMbnq1o121Vm0+neKHUCBtHyseBfDXHA6m4B3mUTWo13nid
 0e4AM71r0DS8+KYh6zvweLX/LL5kQS9GQeT+QNroXcC1NzWbitts6TZ+IrPOwT1hfB4WNC+X
 2n4AzDqp3+ILiVST2DT4VBc11Gz6jijpC/KI5Al8ZDhRwG47LUiuQmt3yqrmN63V9wzaPhC+
 xbwIsNZlLUvuRnmBPkTJwwrFRZvwu5GPHNndBjVpAfaSTOfppyKBTccu2AXJXWAE1Xjh6GOC
 8mlFjZwLxWFqdPHR1n2aPVgoiTLk34LR/bXO+e0GpzFXT7enwyvFFFyAS0Nk1q/7EChPcbRb
 hJqEBpRNZemxmg55zC3GLvgLKd5A09MOM2BrMea+l0FUR+PuTenh2YmnmLRTro6eZ/qYwWkC
 u8FFIw4pT0OUDMyLgi+GI1aMpVogTZJ70FgV0pUAlpmrzk/bLbRkF3TwgucpyPtcpmQtTkWS
 gDS50QG9DR/1As3LLLcNkwJBZzBG6PWbvcOyrwMQUF1nl4SSPV0LLH63+BrrHasfJzxKXzqg
 rW28CTAE2x8qi7e/6M/+XXhrsMYG+uaViM7n2je3qKe7ofum3s4vq7oFCPsOgwARAQABwsFl
 BBgBAgAPBQJVy5+RAhsMBQkJZgGAAAoJEE3eEPcA/4NagOsP/jPoIBb/iXVbM+fmSHOjEshl
 KMwEl/m5iLj3iHnHPVLBUWrXPdS7iQijJA/VLxjnFknhaS60hkUNWexDMxVVP/6lbOrs4bDZ
 NEWDMktAeqJaFtxackPszlcpRVkAs6Msn9tu8hlvB517pyUgvuD7ZS9gGOMmYwFQDyytpepo
 YApVV00P0u3AaE0Cj/o71STqGJKZxcVhPaZ+LR+UCBZOyKfEyq+ZN311VpOJZ1IvTExf+S/5
 lqnciDtbO3I4Wq0ArLX1gs1q1XlXLaVaA3yVqeC8E7kOchDNinD3hJS4OX0e1gdsx/e6COvy
 qNg5aL5n0Kl4fcVqM0LdIhsubVs4eiNCa5XMSYpXmVi3HAuFyg9dN+x8thSwI836FoMASwOl
 C7tHsTjnSGufB+D7F7ZBT61BffNBBIm1KdMxcxqLUVXpBQHHlGkbwI+3Ye+nE6HmZH7IwLwV
 W+Ajl7oYF+jeKaH4DZFtgLYGLtZ1LDwKPjX7VAsa4Yx7S5+EBAaZGxK510MjIx6SGrZWBrrV
 TEvdV00F2MnQoeXKzD7O4WFbL55hhyGgfWTHwZ457iN9SgYi1JLPqWkZB0JRXIEtjd4JEQcx
 +8Umfre0Xt4713VxMygW0PnQt5aSQdMD58jHFxTk092mU+yIHj5LeYgvwSgZN4airXk5yRXl
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d46e3b7e-a0ac-34ce-a04a-c54076ee957b@redhat.com>
Date: Fri, 6 Sep 2019 10:51:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190905101534.9637-3-peterx@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 06 Sep 2019 08:51:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05.09.19 12:15, Peter Xu wrote:
> Although there're tons of arch-specific page fault handlers, most of
> them are still sharing the same initial value of the page fault flags.
> Say, merely all of the page fault handlers would allow the fault to be
> retried, and they also allow the fault to respond to SIGKILL.
> 
> Let's define a default value for the fault flags to replace those
> initial page fault flags that were copied over.  With this, it'll be
> far easier to introduce new fault flag that can be used by all the
> architectures instead of touching all the archs.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  arch/alpha/mm/fault.c      | 2 +-
>  arch/arc/mm/fault.c        | 2 +-
>  arch/arm/mm/fault.c        | 2 +-
>  arch/arm64/mm/fault.c      | 2 +-
>  arch/hexagon/mm/vm_fault.c | 2 +-
>  arch/ia64/mm/fault.c       | 2 +-
>  arch/m68k/mm/fault.c       | 2 +-
>  arch/microblaze/mm/fault.c | 2 +-
>  arch/mips/mm/fault.c       | 2 +-
>  arch/nds32/mm/fault.c      | 2 +-
>  arch/nios2/mm/fault.c      | 2 +-
>  arch/openrisc/mm/fault.c   | 2 +-
>  arch/parisc/mm/fault.c     | 2 +-
>  arch/powerpc/mm/fault.c    | 2 +-
>  arch/riscv/mm/fault.c      | 2 +-
>  arch/s390/mm/fault.c       | 2 +-
>  arch/sh/mm/fault.c         | 2 +-
>  arch/sparc/mm/fault_32.c   | 2 +-
>  arch/sparc/mm/fault_64.c   | 2 +-
>  arch/um/kernel/trap.c      | 2 +-
>  arch/unicore32/mm/fault.c  | 2 +-
>  arch/x86/mm/fault.c        | 2 +-
>  arch/xtensa/mm/fault.c     | 2 +-
>  include/linux/mm.h         | 7 +++++++
>  24 files changed, 30 insertions(+), 23 deletions(-)
> 
> diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
> index 741e61ef9d3f..de4cc6936391 100644
> --- a/arch/alpha/mm/fault.c
> +++ b/arch/alpha/mm/fault.c
> @@ -89,7 +89,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
>  	const struct exception_table_entry *fixup;
>  	int si_code = SEGV_MAPERR;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	/* As of EV6, a load into $31/$f31 is a prefetch, and never faults
>  	   (or is suppressed by the PALcode).  Support that for older CPUs
> diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
> index 3861543b66a0..61919e4e4eec 100644
> --- a/arch/arc/mm/fault.c
> +++ b/arch/arc/mm/fault.c
> @@ -94,7 +94,7 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
>  	         (regs->ecr_cause == ECR_C_PROTV_INST_FETCH))
>  		exec = 1;
>  
> -	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	flags = FAULT_FLAG_DEFAULT;
>  	if (user_mode(regs))
>  		flags |= FAULT_FLAG_USER;
>  	if (write)
> diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
> index 890eeaac3cbb..2ae28ffec622 100644
> --- a/arch/arm/mm/fault.c
> +++ b/arch/arm/mm/fault.c
> @@ -241,7 +241,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
>  	struct mm_struct *mm;
>  	int sig, code;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	if (kprobe_page_fault(regs, fsr))
>  		return 0;
> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
> index cfd65b63f36f..613e7434c208 100644
> --- a/arch/arm64/mm/fault.c
> +++ b/arch/arm64/mm/fault.c
> @@ -410,7 +410,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>  	struct mm_struct *mm = current->mm;
>  	vm_fault_t fault, major = 0;
>  	unsigned long vm_flags = VM_READ | VM_WRITE;
> -	unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int mm_flags = FAULT_FLAG_DEFAULT;
>  
>  	if (kprobe_page_fault(regs, esr))
>  		return 0;
> diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
> index b3bc71680ae4..223787e01bdd 100644
> --- a/arch/hexagon/mm/vm_fault.c
> +++ b/arch/hexagon/mm/vm_fault.c
> @@ -41,7 +41,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
>  	int si_code = SEGV_MAPERR;
>  	vm_fault_t fault;
>  	const struct exception_table_entry *fixup;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	/*
>  	 * If we're in an interrupt or have no user context,
> diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
> index c2f299fe9e04..d039b846f671 100644
> --- a/arch/ia64/mm/fault.c
> +++ b/arch/ia64/mm/fault.c
> @@ -65,7 +65,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
>  	struct mm_struct *mm = current->mm;
>  	unsigned long mask;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	mask = ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
>  		| (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_WRITE_BIT));
> diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
> index e9b1d7585b43..8e734309ace9 100644
> --- a/arch/m68k/mm/fault.c
> +++ b/arch/m68k/mm/fault.c
> @@ -71,7 +71,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct * vma;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	pr_debug("do page fault:\nregs->sr=%#x, regs->pc=%#lx, address=%#lx, %ld, %p\n",
>  		regs->sr, regs->pc, address, error_code, mm ? mm->pgd : NULL);
> diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
> index e6a810b0c7ad..45c9f66c1dbc 100644
> --- a/arch/microblaze/mm/fault.c
> +++ b/arch/microblaze/mm/fault.c
> @@ -91,7 +91,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
>  	int code = SEGV_MAPERR;
>  	int is_write = error_code & ESR_S;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	regs->ear = address;
>  	regs->esr = error_code;
> diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
> index f589aa8f47d9..6660b77ff8f3 100644
> --- a/arch/mips/mm/fault.c
> +++ b/arch/mips/mm/fault.c
> @@ -44,7 +44,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
>  	const int field = sizeof(unsigned long) * 2;
>  	int si_code;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	static DEFINE_RATELIMIT_STATE(ratelimit_state, 5 * HZ, 10);
>  
> diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
> index 064ae5d2159d..a40de112a23a 100644
> --- a/arch/nds32/mm/fault.c
> +++ b/arch/nds32/mm/fault.c
> @@ -76,7 +76,7 @@ void do_page_fault(unsigned long entry, unsigned long addr,
>  	int si_code;
>  	vm_fault_t fault;
>  	unsigned int mask = VM_READ | VM_WRITE | VM_EXEC;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	error_code = error_code & (ITYPE_mskINST | ITYPE_mskETYPE);
>  	tsk = current;
> diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
> index 6a2e716b959f..a401b45cae47 100644
> --- a/arch/nios2/mm/fault.c
> +++ b/arch/nios2/mm/fault.c
> @@ -47,7 +47,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
>  	struct mm_struct *mm = tsk->mm;
>  	int code = SEGV_MAPERR;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	cause >>= 2;
>  
> diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
> index 5d4d3a9691d0..fd1592a56238 100644
> --- a/arch/openrisc/mm/fault.c
> +++ b/arch/openrisc/mm/fault.c
> @@ -50,7 +50,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
>  	struct vm_area_struct *vma;
>  	int si_code;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	tsk = current;
>  
> diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
> index adbd5e2144a3..355e3e13fa72 100644
> --- a/arch/parisc/mm/fault.c
> +++ b/arch/parisc/mm/fault.c
> @@ -274,7 +274,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
>  	if (!mm)
>  		goto no_context;
>  
> -	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	flags = FAULT_FLAG_DEFAULT;
>  	if (user_mode(regs))
>  		flags |= FAULT_FLAG_USER;
>  
> diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
> index 8432c281de92..408ee769c470 100644
> --- a/arch/powerpc/mm/fault.c
> +++ b/arch/powerpc/mm/fault.c
> @@ -435,7 +435,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
>  {
>  	struct vm_area_struct * vma;
>  	struct mm_struct *mm = current->mm;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>   	int is_exec = TRAP(regs) == 0x400;
>  	int is_user = user_mode(regs);
>  	int is_write = page_fault_is_write(error_code);
> diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
> index 96add1427a75..deeb820bd855 100644
> --- a/arch/riscv/mm/fault.c
> +++ b/arch/riscv/mm/fault.c
> @@ -28,7 +28,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
>  	struct vm_area_struct *vma;
>  	struct mm_struct *mm;
>  	unsigned long addr, cause;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  	int code = SEGV_MAPERR;
>  	vm_fault_t fault;
>  
> diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
> index 7b0bb475c166..74a77b2bca75 100644
> --- a/arch/s390/mm/fault.c
> +++ b/arch/s390/mm/fault.c
> @@ -429,7 +429,7 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
>  
>  	address = trans_exc_code & __FAIL_ADDR_MASK;
>  	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
> -	flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	flags = FAULT_FLAG_DEFAULT;
>  	if (user_mode(regs))
>  		flags |= FAULT_FLAG_USER;
>  	if (access == VM_WRITE || (trans_exc_code & store_indication) == 0x400)
> diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
> index 5f51456f4fc7..becf0be267bb 100644
> --- a/arch/sh/mm/fault.c
> +++ b/arch/sh/mm/fault.c
> @@ -380,7 +380,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
>  	struct mm_struct *mm;
>  	struct vm_area_struct * vma;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	tsk = current;
>  	mm = tsk->mm;
> diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
> index 8d69de111470..0863f6fdd2c5 100644
> --- a/arch/sparc/mm/fault_32.c
> +++ b/arch/sparc/mm/fault_32.c
> @@ -168,7 +168,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
>  	int from_user = !(regs->psr & PSR_PS);
>  	int code;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	if (text_fault)
>  		address = regs->pc;
> diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
> index 2371fb6b97e4..a1cba3eef79e 100644
> --- a/arch/sparc/mm/fault_64.c
> +++ b/arch/sparc/mm/fault_64.c
> @@ -267,7 +267,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
>  	int si_code, fault_code;
>  	vm_fault_t fault;
>  	unsigned long address, mm_rss;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	fault_code = get_thread_fault_code();
>  
> diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
> index 58fe36856182..bc2756782d64 100644
> --- a/arch/um/kernel/trap.c
> +++ b/arch/um/kernel/trap.c
> @@ -32,7 +32,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
>  	pmd_t *pmd;
>  	pte_t *pte;
>  	int err = -EFAULT;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	*code_out = SEGV_MAPERR;
>  
> diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
> index 76342de9cf8c..60453c892c51 100644
> --- a/arch/unicore32/mm/fault.c
> +++ b/arch/unicore32/mm/fault.c
> @@ -202,7 +202,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
>  	struct mm_struct *mm;
>  	int sig, code;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	tsk = current;
>  	mm = tsk->mm;
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 9ceacd1156db..994c860ac2d8 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1287,7 +1287,7 @@ void do_user_addr_fault(struct pt_regs *regs,
>  	struct task_struct *tsk;
>  	struct mm_struct *mm;
>  	vm_fault_t fault, major = 0;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	tsk = current;
>  	mm = tsk->mm;
> diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
> index f81b1478da61..d2b082908538 100644
> --- a/arch/xtensa/mm/fault.c
> +++ b/arch/xtensa/mm/fault.c
> @@ -43,7 +43,7 @@ void do_page_fault(struct pt_regs *regs)
>  
>  	int is_write, is_exec;
>  	vm_fault_t fault;
> -	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	unsigned int flags = FAULT_FLAG_DEFAULT;
>  
>  	code = SEGV_MAPERR;
>  
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..57fb5c535f8e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -393,6 +393,13 @@ extern pgprot_t protection_map[16];
>  #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>  #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
>  
> +/*
> + * The default fault flags that should be used by most of the
> + * arch-specific page fault handlers.
> + */
> +#define FAULT_FLAG_DEFAULT  (FAULT_FLAG_ALLOW_RETRY | \
> +			     FAULT_FLAG_KILLABLE)
> +
>  #define FAULT_FLAG_TRACE \
>  	{ FAULT_FLAG_WRITE,		"WRITE" }, \
>  	{ FAULT_FLAG_MKWRITE,		"MKWRITE" }, \
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

