Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CA2EB9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:31:56 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8SK7rNE012657
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:07:53 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8SKVs3b180182
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:31:54 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8SKVrgM013745
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:31:54 -0400
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1109271546320.13797@router.home>
References: <20110927175453.GA3393@albatros>
	 <20110927175642.GA3432@albatros> <20110927193810.GA5416@albatros>
	 <alpine.DEB.2.00.1109271459180.13797@router.home>
	 <alpine.DEB.2.00.1109271328151.24402@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1109271546320.13797@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 28 Sep 2011 13:31:45 -0700
Message-ID: <1317241905.16137.516.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: David Rientjes <rientjes@google.com>, Vasiliy Kulikov <segoon@openwall.com>, kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, 2011-09-27 at 15:47 -0500, Christoph Lameter wrote:
> On Tue, 27 Sep 2011, David Rientjes wrote:
> > It'll turn into another one of our infinite number of capabilities.  Does
> > anything actually care about statistics at KB granularity these days?
> 
> Changing that to MB may also break things. It may be better to have
> consistent system for access control to memory management counters that
> are not related to a process.

We could also just _effectively_ make it output in MB:

	foo = foo & ~(1<<20)

or align-up.  We could also give the imprecise numbers to unprivileged
users and let privileged ones see the page-level ones.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
