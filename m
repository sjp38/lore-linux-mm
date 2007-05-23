Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4NHpkZG003237
	for <linux-mm@kvack.org>; Wed, 23 May 2007 13:51:46 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4NHpjw0211996
	for <linux-mm@kvack.org>; Wed, 23 May 2007 11:51:45 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4NHpiH2032597
	for <linux-mm@kvack.org>; Wed, 23 May 2007 11:51:45 -0600
Date: Wed, 23 May 2007 10:51:42 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/3] hugetlb: numafy several functions
Message-ID: <20070523175142.GB9301@us.ibm.com>
References: <20070516233053.GN20535@us.ibm.com> <20070516233155.GO20535@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070516233155.GO20535@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: Lee.Schermerhorn@hp.com, anton@samba.org, clameter@sgi.com, akpm@linux-foundation.org, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.05.2007 [16:31:55 -0700], Nishanth Aravamudan wrote:
> Add node-parameterized helpers for dequeue_huge_page,
> alloc_fresh_huge_page and try_to_free_low. Also have
> update_and_free_page() take a nid parameter. This is necessary to add a
> per-node sysfs attribute to specify the number of hugepages on that
> node.

I saw that 1/3 was picked up by Andrew, but have not got any responses
to the other two (I know Adam is out of town...).

Thoughts, comments? Bad idea, good idea?

I found it pretty handy to specify the exact layout of hugepages on each
node.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
