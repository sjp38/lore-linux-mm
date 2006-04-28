From: Andi Kleen <ak@suse.de>
Subject: Re: i386 and PAE: pud_present()
Date: Fri, 28 Apr 2006 10:27:21 +0200
References: <aec7e5c30604280040p60cc7c7dqc6fb6fbdd9506a6b@mail.gmail.com> <4451CA41.5070101@yahoo.com.au>
In-Reply-To: <4451CA41.5070101@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604281027.22183.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 28 April 2006 09:54, Nick Piggin wrote:
> Magnus Damm wrote:
> > Hi guys,
> > 
> > In file include/asm-i386/pgtable-3level.h:
> > 
> > On i386 with PAE enabled, shouldn't pud_present() return (pud_val(pud)
> > & _PAGE_PRESENT) instead of constant 1?
> > 
> > Today pud_present() returns constant 1 regardless of PAE or not. This
> > looks wrong to me, but maybe I'm misunderstanding how to fold the page
> > tables... =)
> 
> Take a look a little further down the page for the comment.
> 
> In i386 + PAE, pud is always present.

I think his problem is that the PGD is always present too (in pgtables-nopud.h)
Indeed looks strange.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
