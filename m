Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0F5626B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 07:31:37 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Date: Thu, 2 Apr 2009 22:32:00 +1100
References: <20090327150905.819861420@de.ibm.com> <200903281705.29798.rusty@rustcorp.com.au> <20090329162336.7c0700e9@skybase>
In-Reply-To: <20090329162336.7c0700e9@skybase>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904022232.02185.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, akpm@osdl.org, frankeh@watson.ibm.com, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Monday 30 March 2009 01:23:36 Martin Schwidefsky wrote:
> On Sat, 28 Mar 2009 17:05:28 +1030
>
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> > On Saturday 28 March 2009 01:39:05 Martin Schwidefsky wrote:
> > > Greetings,
> > > the circus is back in town -- another version of the guest page hinting
> > > patches. The patches differ from version 6 only in the kernel version,
> > > they apply against 2.6.29. My short sniff test showed that the code
> > > is still working as expected.
> > >
> > > To recap (you can skip this if you read the boiler plate of the last
> > > version of the patches):
> > > The main benefit for guest page hinting vs. the ballooner is that there
> > > is no need for a monitor that keeps track of the memory usage of all
> > > the guests, a complex algorithm that calculates the working set sizes
> > > and for the calls into the guest kernel to control the size of the
> > > balloons.
> >
> > I thought you weren't convinced of the concrete benefits over ballooning,
> > or am I misremembering?
>
> The performance test I have seen so far show that the benefits of
> ballooning vs. guest page hinting are about the same. I am still
> convinced that the guest page hinting is the way to go because you do
> not need an external monitor. Calculating the working set size for a
> guest is a challenge. With guest page hinting there is no need for a
> working set size calculation.

Sounds backwards to me. If the benefits are the same, then having
complexity in an external monitor (which, by the way, shares many
problems and goals of single-kernel resource/workload management),
rather than putting a huge chunk of crap in the guest kernel's core
mm code.

I still think this needs much more justification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
