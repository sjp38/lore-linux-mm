Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PK0M4Y006697
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 16:00:22 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PK0LJm060194
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 16:00:21 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PK0L79003805
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 16:00:21 -0400
Subject: Re: RFC/POC Make Page Tables Relocatable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
	 <1193340182.24087.54.camel@localhost>
	 <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 13:00:19 -0700
Message-Id: <1193342419.24087.71.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 15:53 -0400, Ross Biro wrote:
> On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> > My guys says that this is way too complicated to be pursued in this
> > form.  But, don't listen to me.  You don't have to convince _me_.
> 
> At this point, I'm more interested if anyone has any objections in
> principle to the overall thing.  If so, and they are legitimate, then
> it's not worth pursuing.  If not, then I'll start.  However, I
> disagree with your order.

Me too!  I just ran through your patch and wrote ideas as I saw them in
your patch order.  I bet they need to be done in much different orders
in reality. 

> I'm thinking more like:
> 
> 1) Support for relocation.

Generic slab relocation, right?

> 2) Support for handles

I've heard these handles are more or less what some other UNIXes do.
That doesn't give it points in my book.  :)

> 3) Test module.
> 
> These three work together and give a framework for validating the
> relocation code with out causing too much trouble.  The only problem
> is that they are mostly useless on their own.

Useless on their own is actually OK.  Patches series are often useless
up until patch 943/943.

> Then the page table related code, using your suggestion above
> (provided I can get it to work.  I'm worried about the page table
> being freed while I'm trying to figure out what mm it belongs to.)
> I'll break this into small chunks.

How would it get freed?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
