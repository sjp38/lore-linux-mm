From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Date: Thu, 25 Sep 2008 21:23:04 +0900 (JST)
Message-ID: <20080925212025.58A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080924154120.GA10837@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754594AbYIYMXU@vger.kernel.org>
In-Reply-To: <20080924154120.GA10837@csn.ul.ie>
Sender: linux-kernel-owner@vger.kernel.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Hi!

> > 1) in normal page, show PAZE_SIZE
> > 
> > because, any userland application woks as pagesize==PAZE_SIZE 
> > on current powerpc architecture.
> > 
> > because
> > 
> > fs/binfmt_elf.c
> > ------------------------------
> > static int
> > create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
> >                 unsigned long load_addr, unsigned long interp_load_addr)
> > {
> > (snip)
> >         NEW_AUX_ENT(AT_HWCAP, ELF_HWCAP);
> >         NEW_AUX_ENT(AT_PAGESZ, ELF_EXEC_PAGESIZE); /* pass ELF_EXEC_PAGESIZE to libc */
> > 
> > include/asm-powerpc/elf.h
> > -----------------------------
> > #define ELF_EXEC_PAGESIZE       PAGE_SIZE 
> > 
> 
> I'm ok with this option and dropping the MMUPageSize patch as the user
> should already be able to identify that the hardware does not support 64K
> base pagesizes. I will leave the name as KernelPageSize so that it is still
> difficult to confuse it with MMU page size.
> 
> > 
> > 2) in normal page, no display any page size.
> >    only hugepage case, display page size.
> > 
> > because, An administrator want to hugepage size only. (AFAICS)
> > 
> 
> I prefer option 1 as it's easier to parse the presense of information
> than infer from the absense of it.

OK.

I'll review and test your latest patch without MMUPageSize part.
(maybe today's midnight or tommorow)

Thanks!
