Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BB3FA8D003B
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 16:28:33 -0500 (EST)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p14LHCgR006664
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 14:17:12 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p14LSSlG157514
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 14:28:28 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p14LSRE0006667
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 14:28:27 -0700
Subject: Re: [RFC][PATCH 1/6] count transparent hugepage splits
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110204211825.GJ30909@random.random>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201003358.98826457@kernel>
	 <alpine.DEB.2.00.1102031235100.453@chino.kir.corp.google.com>
	 <20110204211825.GJ30909@random.random>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 04 Feb 2011 13:28:25 -0800
Message-ID: <1296854905.6737.2631.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>

On Fri, 2011-02-04 at 22:18 +0100, Andrea Arcangeli wrote:
> On Thu, Feb 03, 2011 at 01:22:14PM -0800, David Rientjes wrote:
> > i.e. no global locking, but we've accepted the occassional off-by-one 
> > error (even though splitting of hugepages isn't by any means lightning 
> > fast and the overhead of atomic ops would be negligible).
> 
> Agreed losing an increment is not a problem, but in very large systems
> it will become a bottleneck. It's not super urgent, but I think it
> needs to become a per-cpu counter sooner than later (not needed
> immediately but I would appreciate an incremental patch soon to
> address that). 

Seems like something that would be fairly trivial with the existing
count_vm_event() infrastructure.  Any reason not to use that?  I'll be
happy to tack a patch on to my series.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
