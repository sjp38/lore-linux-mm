Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA00438
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 04:44:18 -0500
Subject: Re: Beta quality write out daemon
References: <m1g19ep3p9.fsf@flinx.ccr.net> <m1iue96lhl.fsf@flinx.ccr.net> <34BD0786.93EEC074@xinit.se> <m1zp7kdi40.fsf@flinx.ccr.net> <m1k8ym4ed2.fsf_-_@flinx.ccr.net>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 17 Jan 1999 23:05:23 -0600
In-Reply-To: ebiederm+eric@ccr.net's message of "17 Jan 1999 00:12:25 -0600"
Message-ID: <m1sod9dvcc.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Hans Eric Sandstrom <hes@xinit.se>
List-ID: <linux-mm.kvack.org>

>>>>> "EB" == Eric W Biederman <ebiederm> writes:

EB> I also seem to have detected a bug in some other part of the kernel.
EB> Where I can find a dirty pte pointing to a swap cache page.

Looking further it's a bug but an unexpected feature.
I thought the invariant that there could be only 1 mapping of a 
of a writeable swappable page.  Would lead to the invariant that
for a writeable swappable page there can be only one dirty page table entry.

When fork does it's Copy On Write split it write protects both the old
and the new page table entries but it leaves both it leaves the dirty bit
set in both of them.  Which really is correct behavior.  Just totally unexpected.

It's taken forever to track this down.  But I at least now that it is
I can move forward.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
