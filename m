Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDH3mIH012925
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 12:03:48 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDH3lu8138714
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 12:03:47 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDH3lve014118
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 12:03:47 -0500
Subject: Re: [RFC][PATCH 1/2] hugetlb: introduce nr_overcommit_hugepages
	sysctl
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071213164908.GE17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com>
	 <1197562629.21438.20.camel@localhost> <20071213164453.GC17526@us.ibm.com>
	 <20071213164908.GE17526@us.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Dec 2007 09:03:44 -0800
Message-Id: <1197565424.21438.26.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: agl@us.ibm.com, wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-13 at 08:49 -0800, Nishanth Aravamudan wrote:
> Hrm, nr_hugepages is documented in vm/hugetlbpage.txt and not
> sysctl/vm.txt Should I document this sysctl there too? 

You might just want to add a pointer to the sysctl file pointing to the
VM documentation.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
