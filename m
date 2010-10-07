Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E8A446B0071
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 03:38:51 -0400 (EDT)
Date: Thu, 7 Oct 2010 09:38:48 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/4] HWPOISON: Report correct address granuality for AO
 huge page errors
Message-ID: <20101007073848.GG5010@basil.fritz.box>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
 <1286398141-13749-4-git-send-email-andi@firstfloor.org>
 <20101007003120.GB9891@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101007003120.GB9891@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 09:31:20AM +0900, Naoya Horiguchi wrote:
> > @@ -198,7 +199,8 @@ static int kill_proc_ao(struct task_struct *t, unsigned long addr, int trapno,
> >  #ifdef __ARCH_SI_TRAPNO
> >  	si.si_trapno = trapno;
> >  #endif
> > -	si.si_addr_lsb = PAGE_SHIFT;
> > +	order = PageCompound(page) ? huge_page_order(page) : PAGE_SHIFT;
>                                                      ^^^^
>                                      huge_page_order(page_hstate(page)) ?

Ok.

> >  				printk(KERN_ERR
> >  		"MCE %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
> > -					pfn, tk->tsk->comm, tk->tsk->pid);
> > +					pfn,	
> > +					tk->tsk->comm, tk->tsk->pid);
> 
> What's the point of this change?

Probably left over from an earlier version; I will drop that hunk thanks.


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
