Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 583F66B0007
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 16:46:39 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id y7-v6so4601839plh.7
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 13:46:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p26-v6sor1817333pli.128.2018.04.12.13.46.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 13:46:38 -0700 (PDT)
Date: Thu, 12 Apr 2018 13:46:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4] mm: remove odd HAVE_PTE_SPECIAL
In-Reply-To: <1523533733-25437-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.21.1804121346250.22780@chino.kir.corp.google.com>
References: <20180411110936.GG23400@dhcp22.suse.cz> <1523533733-25437-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Robin Murphy <robin.murphy@arm.com>, Christophe LEROY <christophe.leroy@c-s.fr>

On Thu, 12 Apr 2018, Laurent Dufour wrote:

> Remove the additional define HAVE_PTE_SPECIAL and rely directly on
> CONFIG_ARCH_HAS_PTE_SPECIAL.
> 
> There is no functional change introduced by this patch
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>
