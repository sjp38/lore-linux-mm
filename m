Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.12.10/8.12.10) with ESMTP id k08C9rln234656
	for <linux-mm@kvack.org>; Sun, 8 Jan 2006 12:09:53 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k08C9quK082730
	for <linux-mm@kvack.org>; Sun, 8 Jan 2006 13:09:52 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k08C9qoI012128
	for <linux-mm@kvack.org>; Sun, 8 Jan 2006 13:09:52 +0100
Date: Sun, 8 Jan 2006 13:09:48 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <20060108120948.GA10688@osiris.ibm.com>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]> <20060107122534.GA20442@osiris.boeblingen.de.ibm.com> <2796BAF66E63B415FF1929B8@[10.1.1.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2796BAF66E63B415FF1929B8@[10.1.1.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Tried to get this running with CONFIG_PTSHARE and CONFIG_PTSHARE_PTE on
> > s390x. Unfortunately it crashed on boot, because pt_share_pte
> > returned a broken pte pointer:
> 
> The patch as submitted only works on i386 and x86_64.  Sorry.

That's why I added what seems to be needed for s390. For CONFIG_PTSHARE and
CONFIG_PTSHARE_PTE it's just a slightly modified Kconfig file.
For CONFIG_PTSHARE_PMD it involves adding a few more pud_* defines to
asm-generic/4level-fixup.h.
Seems to work with the pmd/pud_clear changes as far as I can tell.

Just tested this out of curiousity :)

Thanks,
Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
