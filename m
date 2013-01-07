Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 50D9C6B005A
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 16:53:46 -0500 (EST)
Date: Mon, 7 Jan 2013 13:53:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] pageattr fixes for pmd/pte_present
Message-Id: <20130107135344.5ca426ca.akpm@linux-foundation.org>
In-Reply-To: <1357441197.9001.6.camel@kernel.cn.ibm.com>
References: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
	<1357441197.9001.6.camel@kernel.cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Shaohua Li <shaohua.li@intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Sat, 05 Jan 2013 20:59:57 -0600
Simon Jeons <simon.jeons@gmail.com> wrote:
> 

(top-posting repaired)

top-posting makes it really hard to reply to your email in a useful
fashion.  So if you want a reply, please don't top-post!

> On Mon, 2012-12-17 at 19:00 +0100, Andrea Arcangeli wrote:
> > Hi,
> > 
> > I got a report for a minor regression introduced by commit
> > 027ef6c87853b0a9df53175063028edb4950d476.
> > 
> > So the problem is, pageattr creates kernel pagetables (pte and pmds)
> > that breaks pte_present/pmd_present and the patch above exposed this
> > invariant breakage for pmd_present.
> > 
> > The same problem already existed for the pte and pte_present and it
> > was fixed by commit 660a293ea9be709b893d371fbc0328fcca33c33a (if it
> > wasn't for that commit, it wouldn't even be a regression). That fix
> > avoids the pagefault to use pte_present. I could follow through by
> > stopping using pmd_present/pmd_huge too.
> > 
> > However I think it's more robust to fix pageattr and to clear the
> > PSE/GLOBAL bitflags too in addition to the present bitflag. So the
> > kernel page fault can keep using the regular
> > pte_present/pmd_present/pmd_huge.
> > 
> > The confusion arises because _PAGE_GLOBAL and _PAGE_PROTNONE are
> > sharing the same bit, and in the pmd case we pretend _PAGE_PSE to be
> > set only in present pmds (to facilitate split_huge_page final tlb
> > flush).
> > 
> 
> What's the status of these two patches?

I expect they fell through the christmas cracks.  I added them to my
(getting large) queue of x86 patches for consideration by the x86
maintainers.

Why do you ask?  It seems the bug is a pretty minor one and that we
need only fix it in 3.8 or even 3.9.  Is that supposition incorrect?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
