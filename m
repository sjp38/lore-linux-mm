Date: Wed, 21 Jan 2004 18:16:50 +0200 (EET)
From: logan@osdl.org
Subject: Re: Doubt in do_no_page()
In-Reply-To: <2276.128.2.181.129.1074700039.squirrel@webmail.andrew.cmu.edu>
Message-ID: <Pine.LNX.4.53.0401211803120.3693@osdl>
References: <2276.128.2.181.129.1074700039.squirrel@webmail.andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anand Eswaran <aeswaran@andrew.cmu.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 21 Jan 2004, Anand Eswaran wrote:

>+1 	if (!vma->vm_ops || !vma->vm_ops->nopage)
>+2 		return do_anonymous_page(mm, vma, page_table, write_access, address);
>
> QUESTION
> ------------------------------------------------------------------------
>
>  I assume that most faults would be serviced by the do_anonymous page i.e
> for most "normal" vma's ( say heap ) the vma->vm_ops->nopage would be
> NULL. Is that true?
> ------------------------------------------------------------------------

 No Anand, the page fault is passed to do_anonymous_page
 if vma ( say heap ) does not have its own page processing
 functions ( i.e. ->vm_ops ), the check is made on those first,
 its !vma->vm_ops, and if it has such, the same goes for !vm_ops->nopage.

 You got wrong to for a while.
 But i think code is ok.

 -- Alex
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
