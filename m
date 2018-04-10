Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B59E36B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:42:54 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id r190so8696371qkc.21
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:42:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 80si1971512qkg.344.2018.04.10.09.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 09:42:53 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3AGgDsT044767
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:42:52 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h8ykaw2vm-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:42:52 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 10 Apr 2018 17:42:48 +0100
Subject: Re: [PATCH v2 1/2] mm: introduce ARCH_HAS_PTE_SPECIAL
References: <1523373951-10981-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523373951-10981-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180410160932.GB3614@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 10 Apr 2018 18:42:39 +0200
MIME-Version: 1.0
In-Reply-To: <20180410160932.GB3614@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <a732ef2b-445f-9ad8-014b-247c8c5d500b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>

On 10/04/2018 18:09, Matthew Wilcox wrote:
> On Tue, Apr 10, 2018 at 05:25:50PM +0200, Laurent Dufour wrote:
>>  arch/powerpc/include/asm/pte-common.h                  | 3 ---
>>  arch/riscv/Kconfig                                     | 1 +
>>  arch/s390/Kconfig                                      | 1 +
> 
> You forgot to delete __HAVE_ARCH_PTE_SPECIAL from
> arch/riscv/include/asm/pgtable-bits.h

Damned !
Thanks for catching it.
