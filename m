Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7OGJNqt018250
	for <linux-mm@kvack.org>; Fri, 24 Aug 2007 12:19:24 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7OGJNQd258042
	for <linux-mm@kvack.org>; Fri, 24 Aug 2007 10:19:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7OGJNfh007757
	for <linux-mm@kvack.org>; Fri, 24 Aug 2007 10:19:23 -0600
Subject: Re: [PATCH 9/9] pagemap: export swap ptes
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070824002945.GE21720@waste.org>
References: <20070822231804.1132556D@kernel>
	 <20070822231814.8F5F37A0@kernel>  <20070824002945.GE21720@waste.org>
Content-Type: text/plain
Date: Fri, 24 Aug 2007 09:19:22 -0700
Message-Id: <1187972362.16177.3614.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-23 at 19:29 -0500, Matt Mackall wrote:
> On Wed, Aug 22, 2007 at 04:18:14PM -0700, Dave Hansen wrote:
> > 
> > In addition to understanding which physical pages are
> > used by a process, it would also be very nice to
> > enumerate how much swap space a process is using.
> > 
> > This patch enables /proc/<pid>/pagemap to display
> > swap ptes.  In the process, it also changes the
> > constant that we used to indicate non-present ptes
> > before.
> > 
> > Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
> 
> I suspect you missed a quilt add here, as is_swap_pte is not in any
> header file and is thus implicitly declared.

Yeah, I have another patch that was declared waaaaaaay earlier in my
series that does this.  I'm not completely confident in the way that I
formatted the swap pte, so let's hold off on just this patch for now.
I'll rework it and send it your way again in a few days.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
