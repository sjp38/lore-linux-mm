Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBEItBet432192
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 13:55:11 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBEIt7YB430006
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 11:55:10 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBEIt7ZF001564
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 11:55:07 -0700
Date: Tue, 14 Dec 2004 10:59:50 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <9250000.1103050790@flay>
In-Reply-To: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

> NUMA systems running current Linux kernels suffer from substantial
> inequities in the amount of memory allocated from each NUMA node
> during boot.  In particular, several large hashes are allocated
> using alloc_bootmem, and as such are allocated contiguously from
> a single node each.

Yup, makes a lot of sense to me to stripe these, for the caches that
are global (ie inodes, dentries, etc).  Only question I'd have is 
didn't Manfred or someone (Andi?) do this before? Or did that never
get accepted? I know we talked about it a while back.

M,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
