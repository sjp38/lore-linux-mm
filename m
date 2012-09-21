Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id EFFE26B005A
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 15:16:30 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 21 Sep 2012 15:16:29 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8LJGQ9Q143398
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 15:16:26 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8LJGPDH026001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 15:16:25 -0400
Message-ID: <505CBD05.8080005@linux.vnet.ibm.com>
Date: Fri, 21 Sep 2012 14:16:21 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120921161252.GV11266@suse.de>
In-Reply-To: <20120921161252.GV11266@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 09/21/2012 11:12 AM, Mel Gorman wrote:
> That said, my initial feeling still stands. I think that this needs to move
> out of staging because it's in limbo where it is but Andrew may disagree
> because of the reservations. If my reservations are accurate then they
> should at least be *clearly* documented with a note saying that using
> this in production is ill-advised for now. If zcache is activated via the
> kernel parameter, it should print a big dirty warning that the feature is
> still experiemental and leave that warning there until all the issues are
> addressed. Right now I'm not convinced this is production ready but that
> the  issues could be fixed incrementally.

Thank you _so_ much for the review!  Your comments have
provided one of the few glimpses I've had into any other
thoughts on the code save Dan and my own.

I'm in the process of going through the comments you provided.

I am _very_ glad to hear you believe that zcache should be
promoted out of the staging limbo where it currently
resides.  I am fine with providing a warning against use in
production environments until we can address everyone's
concerns.

Once zcache is promoted, I think it will give the code more
opportunity to be used/improved/extended in an incremental
and stable way.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
