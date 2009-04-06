Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 86D2C5F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 17:54:50 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n36LqWfT019588
	for <linux-mm@kvack.org>; Mon, 6 Apr 2009 15:52:32 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n36LtcxN180390
	for <linux-mm@kvack.org>; Mon, 6 Apr 2009 15:55:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n36Ltc9m010268
	for <linux-mm@kvack.org>; Mon, 6 Apr 2009 15:55:38 -0600
Subject: procps and new kernel fields
From: Dave Hansen <dave@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Mon, 06 Apr 2009 14:55:36 -0700
Message-Id: <1239054936.8846.130.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: bart.vanassche@gmail.com
Cc: linux-mm <linux-mm@kvack.org>, procps-feedback@lists.sf.net, acahalan@cs.uml.edu
List-ID: <linux-mm.kvack.org>

There was a very brief conversation about this a year ago or so.  We've
got a ton of newfangled output in /proc/meminfo, but procps ignores most
of it.  There's also a bunch of types of memory that don't get shown by
the various procps commands these days.

	http://marc.info/?l=linux-mm&m=120496901605830&w=2

Novell has integrated that patch into procps which has the side-effect
that now reclaimable slab and unstable NFS pages are included in the
'cached' output of vmstat and free.  

	https://bugzilla.novell.com/show_bug.cgi?id=405246

The most worrisome side-effect of this change to me is that we can no
longer run vmstat or free on two machines and compare their output.

At the same time, we have machines that have dozens of GB of slab
objects that are mostly reclaimable.  Yet, 'free' and 'vmstat' basically
ignore slab.  Surely we need to find some way to report on those,
especially since we can now break out {un,}reclaimable slab.

We also have "new" memory use like unstable NFS pages.  How should we
account for those?

I'd love to see an --extended output from things like vmstat. It could
include wider output since fitting in 80 columns just isn't that
important any more, and my 256GB machine's output really screws up the
column alignment.  We could also add some information which is in
addition to what we already provide in order to account for things like
slab more precisely.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
