Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7AEF76B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:12:21 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5AF0e4v015883
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:00:40 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5AFBN0f266596
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:11:36 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5AFBMEu015842
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:11:23 -0400
Date: Fri, 10 Jun 2011 08:11:21 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110610151121.GA2230@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110528005640.9076c0b1.akpm@linux-foundation.org>
 <20110609185259.GA29287@linux.vnet.ibm.com>
 <BANLkTinxeeSby_+tta8EhzCg3VbD6+=g+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTinxeeSby_+tta8EhzCg3VbD6+=g+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On Fri, Jun 10, 2011 at 09:51:53AM +0900, Kyungmin Park wrote:
> On Fri, Jun 10, 2011 at 3:52 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Sat, May 28, 2011 at 12:56:40AM -0700, Andrew Morton wrote:
> >> On Fri, 27 May 2011 18:01:28 +0530 Ankita Garg <ankita@in.ibm.com> wrote:
> >>
> >> > This patchset proposes a generic memory regions infrastructure that can be
> >> > used to tag boundaries of memory blocks which belongs to a specific memory
> >> > power management domain and further enable exploitation of platform memory
> >> > power management capabilities.
> >>
> >> A couple of quick thoughts...
> >>
> >> I'm seeing no estimate of how much energy we might save when this work
> >> is completed.  But saving energy is the entire point of the entire
> >> patchset!  So please spend some time thinking about that and update and
> >> maintain the [patch 0/n] description so others can get some idea of the
> >> benefit we might get from all of this.  That estimate should include an
> >> estimate of what proportion of machines are likely to have hardware
> >> which can use this feature and in what timeframe.
> >>
> >> IOW, if it saves one microwatt on 0.001% of machines, not interested ;)
> >
> > FWIW, I have seen estimates on the order of a 5% reduction in power
> > consumption for some common types of embedded devices.
> 
> Wow interesting. I can't expect it can reduce 5% power reduction.
> If it uses the 1GiBytes LPDDR2 memory. each memory port has 4Gib,
> another has 4Gib. so one bank size is 64MiB (512MiB / 8).
> So I don't expect it's difficult to contain the free or inactive
> memory more than 64MiB during runtime.
> 
> Anyway can you describe the exact test environment? esp., memory type?
> As you know there are too much embedded devices which use the various
> environment.

Indeed, your mileage may vary.  It involved a very low-power CPU,
and the change enabled not just powering off memory, but reducing
the amount of physical memory provided.

Of course, on a server, you could get similar results by having a very
large amount of memory (say 256GB) and a workload that needed all the
memory only occasionally for short periods, but could get by with much
less (say 8GB) the rest of the time.  I have no idea whether or not
anyone actually has such a system.

							Thanx, Paul

> Thank you,
> Kyungmin Park
> >
> >                                                        Thanx, Paul
> >
> >> Also, all this code appears to be enabled on all machines?  So machines
> >> which don't have the requisite hardware still carry any additional
> >> overhead which is added here.  I can see that ifdeffing a feature like
> >> this would be ghastly but please also have a think about the
> >> implications of this and add that discussion also.
> >>
> >> If possible, it would be good to think up some microbenchmarks which
> >> probe the worst-case performance impact and describe those and present
> >> the results.  So others can gain an understanding of the runtime costs.
> >>
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> Please read the FAQ at  http://www.tux.org/lkml/
> >>
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
