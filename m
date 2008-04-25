Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PHqqGP009742
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 13:52:52 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PHqqXh212222
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 11:52:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PHqpKS013584
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 11:52:51 -0600
Date: Fri, 25 Apr 2008 10:52:49 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 05/18] hugetlb: multiple hstates
Message-ID: <20080425175249.GE9680@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.162027000@nick.local0.net> <20080425173827.GC9680@us.ibm.com> <20080425175503.GG3265@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425175503.GG3265@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On 25.04.2008 [19:55:03 +0200], Andi Kleen wrote:
> > Unnecessary initializations (and whitespace)?
> 
> Actually gcc generates exactly the same code for 0 and no
> initialization.

All supported gcc's? Then checkpatch should be fixed?

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
