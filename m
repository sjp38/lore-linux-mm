Received: from fmsmsxvs041.fm.intel.com (fmsmsxvs041.fm.intel.com [132.233.42.126])
	by mail2.hd.intel.com (8.11.6/8.11.6/d: solo.mc,v 1.43 2002/08/30 20:06:11 dmccart Exp $) with SMTP id g8HLNBc09950
	for <linux-mm@kvack.org>; Tue, 17 Sep 2002 21:23:11 GMT
Message-ID: <39B5C4829263D411AA93009027AE9EBB13299719@fmsmsx35.fm.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [Lse-tech] Re: Examining the Performance and Cost of Revesema
	ps on 2.5.26 Under  Heavy DBWorkload
Date: Tue, 17 Sep 2002 14:22:36 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
From: Martin J. Bligh [mailto:mbligh@aracnet.com]
Return-Path: <owner-linux-mm@kvack.org>
To: "'Martin J. Bligh'" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>, Peter Wong <wpeter@us.ibm.com>
Cc: linux-mm@kvack.org, lse-tech@lists.sourceforge.net, riel@nl.linux.org, wli@holomorphy.com, dmccr@us.ibm.com, gh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> > That's a ton of memory.  Where do we stand wrt getting these
> > applications to use large-tlb pages?
> 
> We need standard interfaces (like shmem) to get DB2 to port, and probably 
> most other applications. Having magic system calls is all very well in
theory,
> but not much use in practice. 
> 
> And yes, we're still working on it.

Can't you use LD_PRELOAD tricks to sneak a different version shmget/shmat
to your DB2 binary so that you can intercept the important calls and
divert them to use huge tlb pages?

-Tony
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
