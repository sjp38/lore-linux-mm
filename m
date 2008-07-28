Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6SKXa0i021200
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 16:33:36 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6SKXQM9039300
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 14:33:26 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6SKXQd3008838
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 14:33:26 -0600
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <cover.1216928613.git.ebmunson@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
Content-Type: text/plain
Date: Mon, 28 Jul 2008 13:33:24 -0700
Message-Id: <1217277204.23502.36.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Munson <ebmunson@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-28 at 12:17 -0700, Eric Munson wrote:
> 
> This patch stack introduces a personality flag that indicates the
> kernel
> should setup the stack as a hugetlbfs-backed region. A userspace
> utility
> may set this flag then exec a process whose stack is to be backed by
> hugetlb pages.

I didn't see it mentioned here, but these stacks are fixed-size, right?
They can't actually grow and are fixed in size at exec() time, right?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
