Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE69A6B0007
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 12:04:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m190so336761pgm.4
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:04:09 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id e13-v6si578881pln.361.2018.04.09.09.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 09:04:08 -0700 (PDT)
Subject: Re: [PATCH 0/3] move __HAVE_ARCH_PTE_SPECIAL in Kconfig
References: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <17b19aac-fed7-23a2-013c-43ca867152e9@synopsys.com>
Date: Mon, 9 Apr 2018 09:03:49 -0700
MIME-Version: 1.0
In-Reply-To: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, Jerome Glisse <jglisse@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "paulus@samba.org" <paulus@samba.org>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S .  Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo  Molnar <mingo@redhat.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin  Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On 04/09/2018 06:57 AM, Laurent Dufour wrote:
> The per architecture __HAVE_ARCH_PTE_SPECIAL is defined statically in the
> per architecture header files. This doesn't allow to make other
> configuration dependent on it.

So I understand this series has more "readability" value and I'm fine with this 
change but I wonder if you really would want to make something depend on it or 
make this de-configurable. PTE special is really a fundamental construct - e.g. it 
is used for anon mapped pages where zero page has been wired up etc...

-Vineet

> This series is moving the __HAVE_ARCH_PTE_SPECIAL into the Kconfig files,
> setting it automatically when architectures was already setting it in
> header file.
>
> There is no functional change introduced by this series.
