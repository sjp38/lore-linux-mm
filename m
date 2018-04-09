Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2600F6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 10:54:09 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d5so6079872qtg.7
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 07:54:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x128si594046qkd.131.2018.04.09.07.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 07:54:08 -0700 (PDT)
Date: Mon, 9 Apr 2018 10:53:56 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/3] move __HAVE_ARCH_PTE_SPECIAL in Kconfig
Message-ID: <20180409145344.GA3285@redhat.com>
References: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180409140721.GI21835@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180409140721.GI21835@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Mon, Apr 09, 2018 at 04:07:21PM +0200, Michal Hocko wrote:
> On Mon 09-04-18 15:57:06, Laurent Dufour wrote:
> > The per architecture __HAVE_ARCH_PTE_SPECIAL is defined statically in the
> > per architecture header files. This doesn't allow to make other
> > configuration dependent on it.
> > 
> > This series is moving the __HAVE_ARCH_PTE_SPECIAL into the Kconfig files,
> > setting it automatically when architectures was already setting it in
> > header file.
> > 
> > There is no functional change introduced by this series.
> 
> I would just fold all three patches into a single one. It is much easier
> to review that those selects are done properly when you can see that the
> define is set for the same architecture.
> 
> In general, I like the patch. It is always quite painful to track per
> arch defines.

You can also add Reviewed-by: Jerome Glisse <jglisse@redhat> my grep fu
showed no place that was forgotten.

Cheers,
Jerome
