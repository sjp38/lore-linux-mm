Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3DE46B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:47:44 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5AIRJSp019331
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:27:19 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5AIleqc103754
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:47:40 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5AIldR8006750
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:47:40 -0400
Date: Fri, 10 Jun 2011 11:47:38 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110610184738.GG2230@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110609185259.GA29287@linux.vnet.ibm.com>
 <BANLkTinxeeSby_+tta8EhzCg3VbD6+=g+g@mail.gmail.com>
 <20110610151121.GA2230@linux.vnet.ibm.com>
 <20110610155954.GA25774@srcf.ucam.org>
 <20110610165529.GC2230@linux.vnet.ibm.com>
 <20110610170535.GC25774@srcf.ucam.org>
 <20110610171939.GE2230@linux.vnet.ibm.com>
 <20110610172307.GA27630@srcf.ucam.org>
 <20110610175248.GF2230@linux.vnet.ibm.com>
 <20110610180807.GB28500@srcf.ucam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610180807.GB28500@srcf.ucam.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Garrett <mjg59@srcf.ucam.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On Fri, Jun 10, 2011 at 07:08:07PM +0100, Matthew Garrett wrote:
> On Fri, Jun 10, 2011 at 10:52:48AM -0700, Paul E. McKenney wrote:
> > On Fri, Jun 10, 2011 at 06:23:07PM +0100, Matthew Garrett wrote:
> > > I haven't seen too many ARM servers with 256GB of RAM :) I'm mostly 
> > > looking at this from an x86 perspective.
> > 
> > But I have seen ARM embedded systems with CPU power consumption in
> > the milliwatt range, which greatly reduces the amount of RAM required
> > to get significant power savings from this approach.  Three orders
> > of magnitude less CPU power consumption translates (roughly) to three
> > orders of magnitude less memory required -- and embedded devices with
> > more than 256MB of memory are quite common.
> 
> I'm not saying that powering down memory isn't a win, just that in the 
> server market we're not even getting unused memory into self refresh at 
> the moment. If we can gain that hardware capability then sub-node zoning 
> means that we can look at allocating (and migrating?) RAM in such a way 
> as to get a lot of the win that we'd gain from actually cutting the 
> power, without the added overhead of actually shrinking our working set.

Agreed.

And if I understand you correctly, then the patches that Ankita posted
should help your self-refresh case, along with the originally intended
the power-down case and special-purpose use of memory case.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
