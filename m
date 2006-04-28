Message-ID: <4451CA41.5070101@yahoo.com.au>
Date: Fri, 28 Apr 2006 17:54:41 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: i386 and PAE: pud_present()
References: <aec7e5c30604280040p60cc7c7dqc6fb6fbdd9506a6b@mail.gmail.com>
In-Reply-To: <aec7e5c30604280040p60cc7c7dqc6fb6fbdd9506a6b@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:
> Hi guys,
> 
> In file include/asm-i386/pgtable-3level.h:
> 
> On i386 with PAE enabled, shouldn't pud_present() return (pud_val(pud)
> & _PAGE_PRESENT) instead of constant 1?
> 
> Today pud_present() returns constant 1 regardless of PAE or not. This
> looks wrong to me, but maybe I'm misunderstanding how to fold the page
> tables... =)

Take a look a little further down the page for the comment.

In i386 + PAE, pud is always present.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
