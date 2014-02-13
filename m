Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AE1FD6B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:07:09 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so11255266pad.22
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 13:07:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id mj6si3229696pab.304.2014.02.13.13.06.44
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 13:06:45 -0800 (PST)
Date: Thu, 13 Feb 2014 13:06:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
Message-Id: <20140213130643.0cf5fb083056cdd159d1aac4@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org>
	<alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com>
	<20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org>
	<alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com>
	<52F4B8A4.70405@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com>
	<52F88C16.70204@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com>
	<52F8C556.6090006@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
	<52FC6F2A.30905@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Anton Blanchard <anton@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

On Thu, 13 Feb 2014 00:05:31 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Thu, 13 Feb 2014, Raghavendra K T wrote:
> 
> > I was able to test (1) implementation on the system where readahead problem
> > occurred. Unfortunately it did not help.
> > 
> > Reason seem to be that CONFIG_HAVE_MEMORYLESS_NODES dependency of
> > numa_mem_id(). The PPC machine I am facing problem has topology like
> > this:
> > 
> > numactl -H
> > ---------
> > available: 2 nodes (0-1)
> > node 0 cpus: 0 1 2 3 4 5 6 7 12 13 14 15 16 17 18 19 20 21 22 23 24 25
> > ...
> > node 0 size: 0 MB
> > node 0 free: 0 MB
> > node 1 cpus: 8 9 10 11 32 33 34 35 ...
> > node 1 size: 8071 MB
> > node 1 free: 2479 MB
> > node distances:
> > node   0   1
> >   0:  10  20
> >   1:  20  10
> > 
> > So it seems numa_mem_id() does not help for all the configs..
> > Am I missing something ?
> > 
> 
> You need the patch from http://marc.info/?l=linux-mm&m=139093411119013 
> first.

That (un-signed-off) powerpc patch appears to be moribund.  What's up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
