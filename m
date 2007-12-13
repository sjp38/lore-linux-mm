Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDH4V25032236
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 12:04:31 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDH2ljW136164
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 12:02:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDH2kpB029668
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 12:02:47 -0500
Subject: Re: [RFC][PATCH 1/2] hugetlb: introduce nr_overcommit_hugepages
	sysctl
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071213164453.GC17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com>
	 <1197562629.21438.20.camel@localhost>  <20071213164453.GC17526@us.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Dec 2007 09:02:44 -0800
Message-Id: <1197565364.21438.23.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: agl@us.ibm.com, wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-13 at 08:44 -0800, Nishanth Aravamudan wrote:
> Err, yes, will need to updated that. I note that the old sysctl is not
> there...nor is nr_hugepages, for that matter. So maybe I'll just add a
> 3rd patch to fix the Documentation? I really just wanted to get the
> patches out there as soon as I got them tested... 

Yeah, that should be fine.  Adding nr_hugepages will probably get you
bonus points. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
