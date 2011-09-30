Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 410FC9000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 16:16:21 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 30 Sep 2011 16:16:18 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8UKFLAt147222
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 16:15:23 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8UKFH9w015178
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 14:15:17 -0600
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110930130353.0da54517.akpm00@gmail.com>
References: <20110927175453.GA3393@albatros>
	 <20110927175642.GA3432@albatros> <20110927193810.GA5416@albatros>
	 <20110928144614.38591e97.akpm00@gmail.com> <20110930195329.GA2020@albatros>
	 <20110930130353.0da54517.akpm00@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 30 Sep 2011 13:15:14 -0700
Message-ID: <1317413714.16137.666.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm00@gmail.com>
Cc: Vasiliy Kulikov <segoon@openwall.com>, kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

I stuck a printk in there.  It's not exactly called 100x a second, but
there were 5 distinct users just for me to boot and ssh in:

[    3.130408] meminfo read called by: 'udevd' 1
[    3.326649] meminfo read called by: 'dhclient-script' 2
[    4.624943] meminfo read called by: 'klogd' 3
[    8.008019] meminfo read called by: 'dhclient-script' 4
[    8.083091] meminfo read called by: 'ps' 5
[   48.171038] meminfo read called by: 'bash' 6

Granted, those were likely privileged.  But, that's a good list of
processes that I would rather not see break.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
