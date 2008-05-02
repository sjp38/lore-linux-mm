Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m42GIS9Q017064
	for <linux-mm@kvack.org>; Fri, 2 May 2008 12:18:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m42GGJ5I1075736
	for <linux-mm@kvack.org>; Fri, 2 May 2008 12:16:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m42GGJ10008918
	for <linux-mm@kvack.org>; Fri, 2 May 2008 12:16:19 -0400
Subject: Re: [RFC][PATCH 1/2] Add shared and reserve control to
	hugetlb_file_setup
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1209693089.8483.22.camel@grover.beaverton.ibm.com>
References: <1209693089.8483.22.camel@grover.beaverton.ibm.com>
Content-Type: text/plain
Date: Fri, 02 May 2008 09:16:17 -0700
Message-Id: <1209744977.7763.29.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ebmunson@us.ibm.com
Cc: linux-mm@kvack.org, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-01 at 18:51 -0700, Eric B Munson wrote:
> In order to back stacks with huge pages, we will want to make hugetlbfs
> files to back them; these will be used to back private mappings.
> Currently hugetlb_file_setup creates files to back shared memory segments.
> Modify this to create both private and shared files,

Hugetlbfs can currently have private mappings, right?  Why not just use
the existing ones instead of creating a new variety with
hugetlb_file_setup()?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
