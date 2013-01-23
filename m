Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 4CA9F6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 14:04:33 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 23 Jan 2013 14:04:31 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7867B38C803F
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 14:04:29 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0NJ4Sbf322244
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 14:04:29 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0NJ4RjU020710
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 14:04:28 -0500
Message-ID: <51003439.2070505@linux.vnet.ibm.com>
Date: Wed, 23 Jan 2013 13:04:25 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
References: <20130122065341.GA1850@kernel.org> <20130123075808.GH2723@blaptop>
In-Reply-To: <20130123075808.GH2723@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On 01/23/2013 01:58 AM, Minchan Kim wrote:
> Currently, the page table entries that have swapped out pages
> associated with them contain a swap entry, pointing directly
> at the swap device and swap slot containing the data. Meanwhile,
> the swap count lives in a separate array.
> 
> The redesign we are considering moving the swap entry to the
> page cache radix tree for the swapper_space and having the pte
> contain only the offset into the swapper_space.  The swap count
> info can also fit inside the swapper_space page cache radix
> tree (at least on 64 bits - on 32 bits we may need to get
> creative or accept a smaller max amount of swap space).

Correct me if I'm wrong, but this recent patchset creating a
swapper_space per type would mess this up right?  The offset alone
would no longer be sufficient to access the proper swapper_space.

Why not just continue to store the entire swap entry (type and offset)
in the pte?  Where you planning to use the type space in the pte for
something else?

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
