Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EAB226B0062
	for <linux-mm@kvack.org>; Fri,  8 May 2009 13:40:59 -0400 (EDT)
Date: Fri, 8 May 2009 18:37:56 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
 class citizen
Message-ID: <20090508183756.158aa3c3@lxorguk.ukuu.org.uk>
In-Reply-To: <20090508034054.GB1202@eskimo.com>
References: <20090501123541.7983a8ae.akpm@linux-foundation.org>
	<20090503031539.GC5702@localhost>
	<1241432635.7620.4732.camel@twins>
	<20090507121101.GB20934@localhost>
	<alpine.DEB.1.10.0905070935530.24528@qirst.com>
	<1241705702.11251.156.camel@twins>
	<alpine.DEB.1.10.0905071016410.24528@qirst.com>
	<1241712000.18617.7.camel@lts-notebook>
	<alpine.DEB.1.10.0905071231090.10171@qirst.com>
	<4A03164D.90203@redhat.com>
	<20090508034054.GB1202@eskimo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Elladan <elladan@eskimo.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


> I don't think this sort of DOS is relevant for a single user or trusted user
> system.  
> 
> I don't know of any distro that applies default ulimits, so desktops are

A lot of people turn on the vm overcommit protection. In fact if you run
some of the standard desktop apps today its practically essential to deal
with them quietly leaking the box into oblivion or just going mad at
random intervals.

> already susceptible to the far more trivial "call malloc a lot" or "fork bomb"
> attacks.  Plus, ulimits don't help, since they only apply per process - you'd
> need a default mem cgroup before this mattered, I think.

We have a system wide one in effect via the vm overcommit stuff and have
had for years. It works, its relevant and even if it didn't "everything
else sucks" isn't an excuse for more suckage but a call for better things.

If you want any kind of tunable user controllable vm priority then the
obvious things to do would be to borrow the nice() values or implement a
vmnice() for VMAs so users can only say "flog me harder".

Not I fear that it matters - until you fix the two problems of obscenely
bloated leaky apps and bad I/O performance its really an "everything
louder than everything else" kind of argument.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
