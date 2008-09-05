Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m85HdC9h010170
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 13:39:12 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m85HkWlt164368
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 11:46:33 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m85HkVEC027049
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 11:46:32 -0600
Date: Fri, 5 Sep 2008 10:46:29 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] Show memory section to node relationship in sysfs
Message-ID: <20080905174629.GD11692@us.ibm.com>
References: <20080904202212.GB26795@us.ibm.com> <1220566546.23386.65.camel@nimitz> <20080905010010.GE26795@us.ibm.com> <1220636538.23386.128.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1220636538.23386.128.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 05, 2008 at 10:42:18AM -0700, Dave Hansen wrote:
> On Thu, 2008-09-04 at 18:00 -0700, Gary Hade wrote:
> > 
> > In any case, the symlink sounds like a good idea and would be
> > sufficient by itself but I'm wondering if it would be overkill to
> > provide both? e.g. a 'node' symlink and a 'node_num' file.
> 
> Yep, that's overkill.  I'd just do the symlink.

My later conclusion as well.  Thanks.

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
