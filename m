Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7UJ0fbU003070
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 05:00:41 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7UJ4EMW069308
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 05:04:14 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7UJ0ebe018954
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 05:00:40 +1000
Message-ID: <46D713D5.6030709@linux.vnet.ibm.com>
Date: Fri, 31 Aug 2007 00:30:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH]  Memory controller improve user interface (v2)
References: <20070830185246.3170.74806.sendpatchset@balbir-laptop>
In-Reply-To: <20070830185246.3170.74806.sendpatchset@balbir-laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Change the interface to use kilobytes instead of pages. Page sizes can vary
> across platforms and configurations. A new strategy routine has been added
> to the resource counters infrastructure to format the data as desired.
> 

Typo, the description should be

Changelog for version 2

1. Back end tracking is done in bytes, round up values of the limit if the
   specified value is not a multiple of page size. Display memory.usage
   and memory.limit in bytes (Dave Hansen, Paul Menage)

Change the interface to use bytes instead of pages. Page sizes can vary
across platforms and configurations. A new strategy routine has been added
to the resource counters infrastructure to format the data as desired.

Suggested by David Rientjes, Andrew Morton and Herbert Poetzl

Tested on a UML setup with the config for memory control enabled.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
