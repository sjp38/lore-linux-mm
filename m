Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1FIdLJn018532
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 13:39:21 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1FIdKBk269602
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 13:39:20 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1FIdK7i014713
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 13:39:20 -0500
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration --
	sys_page_migrate
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050215105056.GC19658@lnx-holt.americas.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	 <20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>
	 <1108242262.6154.39.camel@localhost>
	 <20050214135221.GA20511@lnx-holt.americas.sgi.com>
	 <1108407043.6154.49.camel@localhost>
	 <20050214220148.GA11832@lnx-holt.americas.sgi.com>
	 <1108419774.6154.58.camel@localhost>
	 <20050215105056.GC19658@lnx-holt.americas.sgi.com>
Content-Type: text/plain
Date: Tue, 15 Feb 2005 10:39:12 -0800
Message-Id: <1108492753.6154.82.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Hugh DIckins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Marcello Tosatti <marcello@cyclades.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-02-15 at 04:50 -0600, Robin Holt wrote:
> What is the fundamental opposition to an array from from-to node mappings?
> They are not that difficult to follow.  They make the expensive traversal
> of ptes the single pass operation.  The time to scan the list of from nodes
> to locate the node this page belongs to is relatively quick when compared
> to the time to scan ptes and will result in probably no cache trashing
> like the long traversal of all ptes in the system required for multiple
> system calls.  I can not see the node array as anything but the right way
> when compared to multiple system calls.  What am I missing?

I don't really have any fundamental opposition.  I'm just trying to make
sure that there's not a simpler (better) way of doing it.  You've
obviously thought about it a lot more than I have, and I'm trying to
understand your process.

As far as the execution speed with a simpler system call.  Yes, it will
likely be slower.  However, I'm not sure that the increase in scan time
is all that significant compared to the migration code (it's pretty
slow).

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
