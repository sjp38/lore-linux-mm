Date: Thu, 27 Apr 2006 13:23:58 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [RFC/PATCH] Shared Page Tables [1/2]
Message-ID: <BD6BD4B5349C1A151BF41FDF@[10.1.1.4]>
In-Reply-To: <44506023.4060609@yahoo.com.au>
References: <1144685591.570.36.camel@wildcat.int.mccr.org>	
 <1144695296.31255.16.camel@localhost.localdomain>	
 <C7A8E6F316A73810A5FF466E@10.1.1.4>
 <aec7e5c30604262049v3ae18915le415ee33b2f80fc4@mail.gmail.com>
 <44506023.4060609@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Magnus Damm <magnus.damm@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Thursday, April 27, 2006 16:09:39 +1000 Nick Piggin
<nickpiggin@yahoo.com.au> wrote:

> Magnus Damm wrote:
>> On 4/11/06, Dave McCracken <dmccr@us.ibm.com> wrote:
> 
>>> No one actually uses any of the pud_page and pgd_page macros (other than
>>> one reference in the same include file).  After some discussion on the
>>> list the last time I posted the patches, we agreed that changing
>>> pud_page and pgd_page to be consistent with pmd_page is the best
>>> solution.  We also agreed that I should go ahead and propagate that
>>> change across all architectures even though not all of them currently
>>> support shared page tables.  This patch is the result of that work.
>> 
>> 
>> What is the merge status of this patch?
>> 
>> I've written some generic page table creation code for kexec, but the
>> fact that pud_page() returns struct page * on i386 but unsigned long
>> on other architectures makes it hard to write clean generic code.
>> 
>> Any merge objections, or was this patch simply overlooked?
> 
> Don't think there would be any objections. If someone sends
> along a broken out patch, I'm sure it could get into 2.6.18.

This patch is broken out.  It only contains the changes necessary to
standardize the pxd_page/pxd_page_kernel macros across the architectures.

As far as I know the only reason it isn't being considered for merge is
that no one other than shared page tables has been using the macros.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
