Received: from e5.ny.us.ibm.com ([192.168.1.105])
	by pokfb.esmtp.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id lBDGIMxj020653
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 11:18:22 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDGHWXb016842
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 11:17:32 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDGHB02358862
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 11:17:32 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDGHBji013506
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 11:17:11 -0500
Subject: Re: [RFC][PATCH 1/2] hugetlb: introduce nr_overcommit_hugepages
	sysctl
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071213074156.GA17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Dec 2007 08:17:08 -0800
Message-Id: <1197562629.21438.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: agl@us.ibm.com, wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-12-12 at 23:41 -0800, Nishanth Aravamudan wrote:
> While examining the code to support /proc/sys/vm/hugetlb_dynamic_pool, I
> became convinced that having a boolean sysctl was insufficient:
> 
> 1) To support per-node control of hugepages, I have previously submitted
> patches to add a sysfs attribute related to nr_hugepages. However, with
> a boolean global value and per-mount quota enforcement constraining the
> dynamic pool, adding corresponding control of the dynamic pool on a
> per-node basis seems inconsistent to me.

Documentation/sysctl, please :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
