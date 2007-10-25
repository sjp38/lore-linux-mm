Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l9PJrkoP030034
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:53:47 +0100
Received: from nf-out-0910.google.com (nfhh3.prod.google.com [10.48.34.3])
	by zps35.corp.google.com with ESMTP id l9PJrej2013914
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:53:45 -0700
Received: by nf-out-0910.google.com with SMTP id h3so605989nfh
        for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:53:45 -0700 (PDT)
Message-ID: <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
Date: Thu, 25 Oct 2007 15:53:45 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: RFC/POC Make Page Tables Relocatable
In-Reply-To: <1193340182.24087.54.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
	 <1193340182.24087.54.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> With the pagetable page you can go examine ptes.  From the ptes, you can
> get the 'struct page' for the mapped page.  From there, you can get the

Definitely worth considering.


> I think you started out with the assumption that we needed out of page
> metadata and then started adding more reasons that we needed it.  I
> seriously doubt that you really and truly *NEED* four new fields in
> 'struct page'. :)

I didn't start off with that assumption.  Originally I intended to add
what I needed to struct page and not worry about it.  However, it
quickly became apparent that while doable, it wouldn't be clean and
that in fact we do have a flexibility issue when it comes to mucking
with something that touches struct page.  That's when I thought up the
meta data thing.

I think it's worth pursuing, but if your suggestion above works, then
it can be totally independent of these changes and I can possibly
substantially shrink struct page when I do the change.  If it all
works well, then it would be self motivating.

>
> My guys says that this is way too complicated to be pursued in this
> form.  But, don't listen to me.  You don't have to convince _me_.

At this point, I'm more interested if anyone has any objections in
principle to the overall thing.  If so, and they are legitimate, then
it's not worth pursuing.  If not, then I'll start.  However, I
disagree with your order.  I'm thinking more like:

1) Support for relocation.
2) Support for handles
3) Test module.

These three work together and give a framework for validating the
relocation code with out causing too much trouble.  The only problem
is that they are mostly useless on their own.

Then the page table related code, using your suggestion above
(provided I can get it to work.  I'm worried about the page table
being freed while I'm trying to figure out what mm it belongs to.)
I'll break this into small chunks.

Finally the metadata code.

Thanks for your input.

     Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
