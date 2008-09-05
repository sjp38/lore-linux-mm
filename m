Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m85HgVG2008951
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 13:42:31 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m85HgLVY161008
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 13:42:21 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m85HgKBh020432
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 13:42:21 -0400
Subject: Re: [PATCH] Show memory section to node relationship in sysfs
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080905010010.GE26795@us.ibm.com>
References: <20080904202212.GB26795@us.ibm.com>
	 <1220566546.23386.65.camel@nimitz>  <20080905010010.GE26795@us.ibm.com>
Content-Type: text/plain
Date: Fri, 05 Sep 2008 10:42:18 -0700
Message-Id: <1220636538.23386.128.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-09-04 at 18:00 -0700, Gary Hade wrote:
> 
> In any case, the symlink sounds like a good idea and would be
> sufficient by itself but I'm wondering if it would be overkill to
> provide both? e.g. a 'node' symlink and a 'node_num' file.

Yep, that's overkill.  I'd just do the symlink.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
