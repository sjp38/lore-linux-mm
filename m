Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77F106B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 01:34:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b25-v6so10501116pfn.10
        for <linux-mm@kvack.org>; Mon, 21 May 2018 22:34:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j5-v6sor6270790pfi.86.2018.05.21.22.34.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 22:34:21 -0700 (PDT)
Date: Tue, 22 May 2018 15:34:11 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: Why do we let munmap fail?
Message-ID: <20180522153411.3b061683@roar.ozlabs.ibm.com>
In-Reply-To: <CAKOZuesScfm_5=2FYurY3ojdhQtcwPWY+=hayJ5cG7pQU1LP9g@mail.gmail.com>
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
	<aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com>
	<CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
	<e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com>
	<CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
	<20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com>
	<CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
	<2e7fb27e-90b4-38d2-8ae1-d575d62c5332@intel.com>
	<CAKOZueu8ckN1b-cYOxPhL5f7Bdq+LLRP20NK3x7Vtw79oUT3pg@mail.gmail.com>
	<20c9acc2-fbaf-f02d-19d7-2498f875e4c0@intel.com>
	<CAKOZuesScfm_5=2FYurY3ojdhQtcwPWY+=hayJ5cG7pQU1LP9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: dave.hansen@intel.com, linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, 21 May 2018 17:00:47 -0700
Daniel Colascione <dancol@google.com> wrote:

> On Mon, May 21, 2018 at 4:32 PM Dave Hansen <dave.hansen@intel.com> wrote:
> 
> > On 05/21/2018 04:16 PM, Daniel Colascione wrote:  
> > > On Mon, May 21, 2018 at 4:02 PM Dave Hansen <dave.hansen@intel.com>  
> wrote:
> > >  
> > >> On 05/21/2018 03:54 PM, Daniel Colascione wrote:  
> > >>>> There are also certainly denial-of-service concerns if you allow
> > >>>> arbitrary numbers of VMAs.  The rbtree, for instance, is O(log(n)),  
> but
> > >>>> I 'd be willing to be there are plenty of things that fall over if  
> you
> > >>>> let the ~65k limit get 10x or 100x larger.  
> > >>> Sure. I'm receptive to the idea of having *some* VMA limit. I just  
> think
> > >>> it's unacceptable let deallocation routines fail.  
> > >> If you have a resource limit and deallocation consumes resources, you
> > >> *eventually* have to fail a deallocation.  Right?  
> > > That's why robust software sets aside at allocation time whatever  
> resources
> > > are needed to make forward progress at deallocation time.  
> 
> > I think there's still a potential dead-end here.  "Deallocation" does
> > not always free resources.  
> 
> Sure, but the general principle applies: reserve resources when you *can*
> fail so that you don't fail where you can't fail.

munmap != deallocation, it's a request to change the address mapping.
A more complex mapping uses more resources. mmap can free resources
if it transforms your mapping to a simpler one.

Thanks,
Nick
