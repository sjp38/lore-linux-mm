Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j0QI1vSK006635
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 13:01:57 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0QI1shu275922
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 13:01:57 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j0QI1s0h019300
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 13:01:54 -0500
Subject: Re: [RFC][PATCH 0/5] consolidate i386 NUMA init code
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <15640000.1106750236@flay>
References: <1106698985.6093.39.camel@localhost>  <15640000.1106750236@flay>
Content-Type: text/plain
Date: Wed, 26 Jan 2005 10:01:49 -0800
Message-Id: <1106762509.6093.67.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-01-26 at 06:37 -0800, Martin J. Bligh wrote:
> > The following five patches reorganize and consolidate some of the i386
> > NUMA/discontigmem code.  They grew out of some observations as we
> > produced the memory hotplug patches.
> > 
> > Only the first one is really necessary, as it makes the implementation
> > of one of the hotplug components much simpler and smaller.  2 and 3 came
> > from just looking at the effects on the code after 1.
> > 
> > 4 and 5 aren't absolutely required for hotplug either, but do allow
> > sharing a bunch of code between the normal boot-time init and hotplug
> > cases.  
> > 
> > These are all on top of 2.6.11-rc2-mm1.
> 
> Looks reasonable. How much testing have they had, on what platforms?

Built on all the i386 configs here:
http://sr71.net/patches/2.6.11/2.6.11-rc1-mm1-mhp1/configs/

Booted on x440 (summit and generic), numaq, 4-way PIII.  I would imagine
that any problem would manifest as the system simply not booting.  The
most likely to fail would be systems with DISCONTIG enabled, because
that's where the greatest amount of churn happened.  The normal !
DISCONTIG case still uses most of the same code.

Anyway, I think they're probably ready for a run in -mm, with the "if
the machines don't boot check these first" flag set.  Although, I'd
appreciate any other testing that anyone wants to throw at them.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
