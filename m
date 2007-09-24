Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8OLoc1I032209
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 17:50:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8OLocER488294
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 15:50:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8OLocb4003905
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 15:50:38 -0600
Subject: Re: + maps2-export-page-index-in-kpagemap.patch added to -mm tree
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070924213549.GJ19691@waste.org>
References: <200709242044.l8OKi01e016834@imap1.linux-foundation.org>
	 <20070924205901.GI19691@waste.org> <1190668988.26982.254.camel@localhost>
	 <20070924213549.GJ19691@waste.org>
Content-Type: text/plain
Date: Mon, 24 Sep 2007 14:50:36 -0700
Message-Id: <1190670636.26982.258.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, balbir@linux.vnet.ibm.com, jjberthels@gmail.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-24 at 16:35 -0500, Matt Mackall wrote:
> On Mon, Sep 24, 2007 at 02:23:08PM -0700, Dave Hansen wrote:
> > Could someone elaborate a little bit more on exactly why you'd want to
> > know which parts of the file are mapped? 
> 
> Google codesearch finds one actual user of remap_file_pages (and
> -lots- of false positives) in an obscure webserver, so I think the
> answer somehow involves Oracle.

If you're asking yourself wtf Oracle is doing, I can see how this is
helpful.  But, since Oracle has to maintain its own internal mappings of
what it remapped, this shouldn't help Oracle itself.

In any case, even if you realize that Oracle is misusing
(under-utilizing?) its remapped areas, what do you do?  You have to go
dig into Oracle to find out what it was doing.  That is precisely what
you would have had to do in the first place without this patch.  I don't
quite get what this buys us. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
