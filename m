Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 05CEF8D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 12:54:40 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p18HTT50000328
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 12:29:29 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D0EF872804B
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 12:54:37 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p18HsbkD409948
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 12:54:37 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p18HsbRf024180
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 12:54:37 -0500
Subject: Re: [RFC][PATCH 0/6] more detailed per-process transparent
 hugepage statistics
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110202000750.GC16981@random.random>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201153857.GA18740@random.random> <1296580547.27022.3370.camel@nimitz>
	 <20110201203936.GB16981@random.random> <1296593801.27022.3920.camel@nimitz>
	 <20110202000750.GC16981@random.random>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 08 Feb 2011 09:54:34 -0800
Message-ID: <1297187674.6737.12145.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2011-02-02 at 01:07 +0100, Andrea Arcangeli wrote:
> > I guess we could also try and figure out whether the khugepaged CPU
> > overhead really comes from the scanning or the collapsing operations
> > themselves.  Should be as easy as some oprofiling.
> 
> Actually I already know, the scanning is super fast. So it's no real
> big deal to increase the scanning. It's big deal only if there are
> plenty more of collapse/split. Compared to the KSM scan, the
> khugepaged scan costs nothing.

Just FYI, I did some profiling on a workload that constantly split and
joined pages.  Very little of the overhead was in the scanning itself,
so I think you're dead-on here.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
