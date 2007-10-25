Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PKFNep020143
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 16:15:23 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PKFN02103604
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:15:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PKFMFM016138
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:15:22 -0600
Subject: Re: RFC/POC Make Page Tables Relocatable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <d43160c70710251258m745c70a7t462cad964ffb2f9f@mail.gmail.com>
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
	 <1193340182.24087.54.camel@localhost>
	 <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
	 <d43160c70710251258m745c70a7t462cad964ffb2f9f@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 13:15:21 -0700
Message-Id: <1193343321.24087.75.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 15:58 -0400, Ross Biro wrote:
> On 10/25/07, Ross Biro <rossb@google.com> wrote:
> > On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> > > With the pagetable page you can go examine ptes.  From the ptes, you can
> > > get the 'struct page' for the mapped page.  From there, you can get the
> >
> > Definitely worth considering.
> 
> Now I remember.  At least in the slab allocator, the relocation code
> must hold an important spinlock while the relocation occurs.  Maybe I
> can get around that, but maybe not.  If not, that could be a
> fundamental problem, but at least it prevents doing long searches.

"important spinlock" isn't really precise enough for me to understand
what you are talking about, make any arguments for or against it, or
suggest alternatives. :(

If the slab is truly a constraint, perhaps you should consider alternate
mechanisms, or fix the slab instead.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
