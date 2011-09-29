Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2359000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:50:49 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 29 Sep 2011 13:48:30 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8THlWJJ259560
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:47:32 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8THlVvH008086
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:47:31 -0400
Message-ID: <4E84AF30.30402@linux.vnet.ibm.com>
Date: Thu, 29 Sep 2011 12:47:28 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: gregkh@suse.de, dan.magenheimer@oracle.com, ngupta@vflare.org, cascardo@holoscopio.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, linux-mm@kvack.org, rcj@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, brking@linux.vnet.ibm.com

On 09/07/2011 09:09 AM, Seth Jennings wrote:
> 
> I did some quick tests with "time" using the same program and the
> timings are very close (3 run average, little deviation):
> 
> xvmalloc:
> zero filled	0m0.852s
> text (75%)	0m14.415s
> 
> xcfmalloc:
> zero filled	0m0.870s
> text (75%)	0m15.089s
> 
> I suspect that the small decrease in throughput is due to the
> extra memcpy in xcfmalloc.  However, these timing, more than 
> anything, demonstrate that the throughput is GREATLY effected
> by the compressibility of the data.

This is not correct.  I found out today that the reason text
compressed so much more slowly is because my test program
was inefficiently filling text filled pages.

With my corrected test program:
xvmalloc:
zero filled	0m0.751s
text (75%)	0m2.273s

It is still slower on less compressible data but not to the
degree previously stated.

I don't have the xcfmalloc numbers yet, but I expect they are
almost the same.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
