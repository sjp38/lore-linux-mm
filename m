Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m1DGCnSQ037144
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 16:12:49 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1DGCn0Z2248898
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 17:12:49 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1DGCmeR007624
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 17:12:48 +0100
In-Reply-To: <adazlu5vlub.fsf@cisco.com>
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>	<20080208155641.2258ad2c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802081603430.4543@schroedinger.engr.sgi.com>	<adaprv70yyt.fsf@cisco.com>
	<Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com>	<adalk5v0yi6.fsf@cisco.com>
	<Pine.LNX.4.64.0802081634070.5298@schroedinger.engr.sgi.com>	<20080209012446.GB7051@v2.random>
	<Pine.LNX.4.64.0802081725200.5445@schroedinger.engr.sgi.com>	<20080209015659.GC7051@v2.random>
	<Pine.LNX.4.64.0802081813300.5602@schroedinger.engr.sgi.com>	<20080209075556.63062452@bree.surriel.com>
	<Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com>	<ada3arzxgkz.fsf_-_@cisco.com>
	<47B2174E.5000708@opengridcomputing.com>	<Pine.LNX.4.64.0802121408150.9591@schroedinger
 <adazlu5vlub.fsf@cisco.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <OF02DFC038.7260E7CB-ONC12573EE.0047FE76-C12573EE.0042EBE0@de.ibm.com>
From: Christoph Raisch <RAISCH@de.ibm.com>
Date: Wed, 13 Feb 2008 13:11:51 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roland Dreier <rdreier@cisco.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, avi@qumranet.com, a.p.zijlstra@chello.nl, Christoph Lameter <clameter@sgi.com>, daniel.blueman@quadrics.com, general@lists.openfabrics.org, general-bounces@lists.openfabrics.org, Robin Holt <holt@sgi.com>, izike@qumranet.com, kvm-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

>  > > Chelsio's T3 HW doesn't support this.


For ehca we currently can't modify a large MR when it has been allocated.
EHCA Hardware expects the pages to be there (MRs must not have "holes").
This is also true for the global MR covering all kernel space.
Therefore we still need the memory to be "pinned" if ib_umem_get() is
called.

So with the current implementation we don't have much use for a notifier.


"It is difficult to make predictions, especially about the future"
Gruss / Regards
Christoph Raisch + Hoang-Nam Nguyen



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
