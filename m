Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8P8I0Hw017869
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 18:18:00 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8P8LWLU257466
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 18:21:32 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8P8Hsue016087
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 18:17:57 +1000
Message-ID: <46F8C426.3090300@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2007 13:47:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: + maps2-export-page-index-in-kpagemap.patch added to -mm tree
References: <200709242044.l8OKi01e016834@imap1.linux-foundation.org> <20070924205901.GI19691@waste.org> <1190668988.26982.254.camel@localhost> <20070924213549.GJ19691@waste.org> <1190670636.26982.258.camel@localhost> <20070924220202.GK19691@waste.org> <390704784.02057@ustc.edu.cn>
In-Reply-To: <390704784.02057@ustc.edu.cn>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: Matt Mackall <mpm@selenic.com>, Dave Hansen <haveblue@us.ibm.com>, akpm@linux-foundation.org, jjberthels@gmail.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Fengguang Wu wrote:
> On Mon, Sep 24, 2007 at 05:02:02PM -0500, Matt Mackall wrote:
>> I think Fengguang is just thinking forward to the next logical step
>> here which is "expose what's in the page cache". Which means being
> 
> I have been doing it for a long time - that's the filecache patch I
> sent you. However it's not quite ready for a public review.
> 
>> able to go from page back to device:inode:offset or (better, but
>> trickier) path:offset.
> 
> It's doing the other way around - a top-down way.
> 
> First, you get a table of all cached inodes with the following fields:
>   device-number  inode-number  file-path  cached-page-count  status
> 
> Then, one can query any file he's interested in, and list all its
> cached pages in the following format:
>   index  length  page-flags  reference-count

This design sounds good to me, I would expect people using madvise()
to probably use this interface. Questions on the interface

1. What permissions would a program need to use the interface
2. Do we export both mapped and unmapped page cache. How does this
   interface gel with mincore(2)? Is there duplicate information
3. If the user already knows the file of interest, is it possible
   to list, it's cached pages without having to list all cached inodes
4. What's the size of data (expected average) and the format, binary
   or text?


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
