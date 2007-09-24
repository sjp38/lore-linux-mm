Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l8OKF4xe022154
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 16:15:04 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8OLNAYP502812
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 15:23:10 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8OLNA6D027549
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 15:23:10 -0600
Subject: Re: + maps2-export-page-index-in-kpagemap.patch added to -mm tree
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070924205901.GI19691@waste.org>
References: <200709242044.l8OKi01e016834@imap1.linux-foundation.org>
	 <20070924205901.GI19691@waste.org>
Content-Type: text/plain
Date: Mon, 24 Sep 2007 14:23:08 -0700
Message-Id: <1190668988.26982.254.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, balbir@linux.vnet.ibm.com, jjberthels@gmail.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-24 at 15:59 -0500, Matt Mackall wrote:
> 
> If we really must do this, it'd be better to have a parallel file with
> the offsets.

Yeah, I'd much rather have a couple of files with really, really simple
and _stable_ formats than one with a more complex and variable one.  

Although you can't answer the "which parts are mapped" question without
the page_index() information, you can answer the "what percentage of
this file is actively mapped" question.

Could someone elaborate a little bit more on exactly why you'd want to
know which parts of the file are mapped? 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
