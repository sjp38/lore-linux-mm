Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8OLJkUj010825
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 17:19:46 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8OLJk8j488328
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 15:19:46 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8OLJkX1013628
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 15:19:46 -0600
Subject: Re: + maps2-export-page-index-in-kpagemap.patch added to -mm tree
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200709242044.l8OKi01e016834@imap1.linux-foundation.org>
References: <200709242044.l8OKi01e016834@imap1.linux-foundation.org>
Content-Type: text/plain
Date: Mon, 24 Sep 2007 14:19:44 -0700
Message-Id: <1190668784.26982.250.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: wfg@mail.ustc.edu.cn, balbir@linux.vnet.ibm.com, jjberthels@gmail.com, mpm@selenic.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-24 at 13:44 -0700, akpm@linux-foundation.org wrote:
> 
> 
> To analyze/optimize the memory footprint, the number one question
> people
> may ask about pagemap/kpagemap could be:
> 
>         Which part of the files are being actively mapped?
> 
> In the (rare) case of nonlinear mapping, that question could only be
> answered by explicitly exporting the page index in kpagemap.  Simply
> judging by the PFNs from pagemap could be wrong! 

I'll look over this in some more detail, but I have the feeling KPMSIZE
reintroduces the overrunning of users' buffers bug.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
