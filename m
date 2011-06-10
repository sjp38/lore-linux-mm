Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CFE8E6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:19:42 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5AGvEFq008494
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 12:57:14 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5AHJfoN048984
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:19:41 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5AHJe17030452
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:19:41 -0400
Date: Fri, 10 Jun 2011 10:19:39 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110610171939.GE2230@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110528005640.9076c0b1.akpm@linux-foundation.org>
 <20110609185259.GA29287@linux.vnet.ibm.com>
 <BANLkTinxeeSby_+tta8EhzCg3VbD6+=g+g@mail.gmail.com>
 <20110610151121.GA2230@linux.vnet.ibm.com>
 <20110610155954.GA25774@srcf.ucam.org>
 <20110610165529.GC2230@linux.vnet.ibm.com>
 <20110610170535.GC25774@srcf.ucam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610170535.GC25774@srcf.ucam.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Garrett <mjg59@srcf.ucam.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On Fri, Jun 10, 2011 at 06:05:35PM +0100, Matthew Garrett wrote:
> On Fri, Jun 10, 2011 at 09:55:29AM -0700, Paul E. McKenney wrote:
> > On Fri, Jun 10, 2011 at 04:59:54PM +0100, Matthew Garrett wrote:
> > > For the server case, the low hanging fruit would seem to be 
> > > finer-grained self-refresh. At best we seem to be able to do that on a 
> > > per-CPU socket basis right now. The difference between active and 
> > > self-refresh would seem to be much larger than the difference between 
> > > self-refresh and powered down.
> > 
> > By "finer-grained self-refresh" you mean turning off refresh for banks
> > of memory that are not being used, right?  If so, this is supported by
> > the memory-regions support provided, at least assuming that the regions
> > can be aligned with the self-refresh boundaries.
> 
> I mean at the hardware level. As far as I know, the best we can do at 
> the moment is to put an entire node into self refresh when the CPU hits 
> package C6.

But this depends on the type of system and CPU family, right?  If you
can say, which hardware are you thinking of?  (I am thinking of ARM.)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
