Received: from talaria.fm.intel.com (talaria.fm.intel.com [10.1.192.39])
	by hermes.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h1BLdux11747
	for <linux-mm@kvack.org>; Tue, 11 Feb 2003 21:39:56 GMT
Received: from fmsmsxv040-1.fm.intel.com (fmsmsxvs040.fm.intel.com [132.233.42.124])
	by talaria.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h1BLieX03866
	for <linux-mm@kvack.org>; Tue, 11 Feb 2003 21:44:40 GMT
content-class: urn:content-classes:message
Subject: RE: [Lse-tech] [rfc][api] Shared Memory Binding
Date: Tue, 11 Feb 2003 13:42:53 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Message-ID: <DD755978BA8283409FB0087C39132BD1A07CD2@fmsmsx404.fm.intel.com>
Content-Transfer-Encoding: 8BIT
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com, "Martin J. Bligh" <mbligh@aracnet.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech@lists.sourceforge.net, Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 	I've got a pseudo manpage for a new call I'm attempting 
> to implement: 
> shmbind().  The idea of the call is to allow userspace 
> processes to bind 
> shared memory segments to particular nodes' memory and do so 
> according 
> to certain policies.  Processes would call shmget() as usual, 
> but before 
> calling shmat(), the process could call shmbind() to set up a binding 
> for the segment.  Then, any time pages from the shared segment are 
> faulted into memory, it would be done according to this binding.
> 	Any comments about the attatched manpage, the idea in 
> general, how to improve it, etc. are definitely welcome.

Why tie this to the sysV ipc shm mechanism?  Couldn't you make
a more general "mmbind()" call that applies to a "start, len"
range of virtual addresses?  This would work for your current
usage (but you would apply it after the "shmat()"), but it would
also be useful for memory allocated to a process with mmap(), sbrk()
and even general .text/.data if you managed to call it before you
touched pages.

-Tony
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
