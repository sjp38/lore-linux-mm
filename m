Date: Sun, 08 Jan 2006 08:04:36 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <12ABD688F4CA0F871A33F535@[10.1.1.4]>
In-Reply-To: <20060108120948.GA10688@osiris.ibm.com>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <20060107122534.GA20442@osiris.boeblingen.de.ibm.com>
 <2796BAF66E63B415FF1929B8@[10.1.1.4]>
 <20060108120948.GA10688@osiris.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Sunday, January 08, 2006 13:09:48 +0100 Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:

>> The patch as submitted only works on i386 and x86_64.  Sorry.
> 
> That's why I added what seems to be needed for s390. For CONFIG_PTSHARE
> and CONFIG_PTSHARE_PTE it's just a slightly modified Kconfig file.
> For CONFIG_PTSHARE_PMD it involves adding a few more pud_* defines to
> asm-generic/4level-fixup.h.
> Seems to work with the pmd/pud_clear changes as far as I can tell.

Wow.  That's good to know.  Thanks.

Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
