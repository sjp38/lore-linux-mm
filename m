Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 654426B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 12:55:36 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5AGX3Ka014277
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 12:33:03 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5AGtUlK1265828
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 12:55:30 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5AGtTR5019079
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 12:55:30 -0400
Date: Fri, 10 Jun 2011 09:55:29 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110610165529.GC2230@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110528005640.9076c0b1.akpm@linux-foundation.org>
 <20110609185259.GA29287@linux.vnet.ibm.com>
 <BANLkTinxeeSby_+tta8EhzCg3VbD6+=g+g@mail.gmail.com>
 <20110610151121.GA2230@linux.vnet.ibm.com>
 <20110610155954.GA25774@srcf.ucam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610155954.GA25774@srcf.ucam.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Garrett <mjg59@srcf.ucam.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On Fri, Jun 10, 2011 at 04:59:54PM +0100, Matthew Garrett wrote:
> On Fri, Jun 10, 2011 at 08:11:21AM -0700, Paul E. McKenney wrote:
> 
> > Of course, on a server, you could get similar results by having a very
> > large amount of memory (say 256GB) and a workload that needed all the
> > memory only occasionally for short periods, but could get by with much
> > less (say 8GB) the rest of the time.  I have no idea whether or not
> > anyone actually has such a system.
> 
> For the server case, the low hanging fruit would seem to be 
> finer-grained self-refresh. At best we seem to be able to do that on a 
> per-CPU socket basis right now. The difference between active and 
> self-refresh would seem to be much larger than the difference between 
> self-refresh and powered down.

By "finer-grained self-refresh" you mean turning off refresh for banks
of memory that are not being used, right?  If so, this is supported by
the memory-regions support provided, at least assuming that the regions
can be aligned with the self-refresh boundaries.

Or am I missing your point?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
