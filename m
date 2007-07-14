Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l6EKZx8Y014351
	for <linux-mm@kvack.org>; Sat, 14 Jul 2007 16:35:59 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6EKfY33269638
	for <linux-mm@kvack.org>; Sat, 14 Jul 2007 14:41:34 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6EKfXup024416
	for <linux-mm@kvack.org>; Sat, 14 Jul 2007 14:41:34 -0600
Date: Sat, 14 Jul 2007 13:41:33 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v8] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070714204133.GC17929@us.ibm.com>
References: <20070714203733.GA17929@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070714203733.GA17929@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, kxr@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.07.2007 [13:37:33 -0700], Nishanth Aravamudan wrote:
> Fix hugetlb pool allocation with empty nodes

Clearly, this should have been [1/3], sorry for the mistake.

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
