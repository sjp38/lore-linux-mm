Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7C36B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 12:17:33 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m77so4652023wma.4
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:17:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o13si722652edh.136.2018.04.09.09.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 09:17:31 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w39GFxD2120231
	for <linux-mm@kvack.org>; Mon, 9 Apr 2018 12:17:30 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h8a06w6xp-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Apr 2018 12:17:29 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Apr 2018 17:17:27 +0100
Subject: Re: [PATCH 0/3] move __HAVE_ARCH_PTE_SPECIAL in Kconfig
References: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <17b19aac-fed7-23a2-013c-43ca867152e9@synopsys.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 9 Apr 2018 18:17:16 +0200
MIME-Version: 1.0
In-Reply-To: <17b19aac-fed7-23a2-013c-43ca867152e9@synopsys.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <21c34965-ec30-4d7f-aeaf-cb3da9758a0e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, Jerome Glisse <jglisse@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "paulus@samba.org" <paulus@samba.org>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On 09/04/2018 18:03, Vineet Gupta wrote:
> On 04/09/2018 06:57 AM, Laurent Dufour wrote:
>> The per architecture __HAVE_ARCH_PTE_SPECIAL is defined statically in the
>> per architecture header files. This doesn't allow to make other
>> configuration dependent on it.
> 
> So I understand this series has more "readability" value and I'm fine with this
> change but I wonder if you really would want to make something depend on it or
> make this de-configurable. PTE special is really a fundamental construct - e.g.
> it is used for anon mapped pages where zero page has been wired up etc...

I don't want it to be de-configurable. This is almost like
ARCH_SUPPORTS_MEMORY_FAILURE, ARCH_USES_HIGH_VMA_FLAGS, ARCH_HAS_HMM...

These values are selected by per architecture Kconfig files and are not exposed
through the configuration menu.

Concerning making something depend on it, I will probably make
CONFIG_SPECULATIVE_PAGE_FAULT introduced by the SPF series dependent on it.
For details, please see https://lkml.org/lkml/2018/3/13/1143

Thanks,
Laurent.
