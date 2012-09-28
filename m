Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id BDB676B0072
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:31:36 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:31:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC/PATCH] zcache2 on PPC64 (Was: [RFC] mm: add support for
 zsmalloc and zcache)
Message-ID: <20120928133121.GH29125@suse.de>
References: <30a570e8-8157-47e1-867a-4960a7c1173d@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <30a570e8-8157-47e1-867a-4960a7c1173d@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, James Bottomley <James.Bottomley@HansenPartnership.com>

On Tue, Sep 25, 2012 at 04:31:01PM -0700, Dan Magenheimer wrote:
> Attached patch applies to staging-next and I _think_ should
> fix the reported problem where zbud in zcache2 does not
> work on a PPC64 with PAGE_SIZE!=12.  I do not have a machine
> to test this so testing by others would be appreciated.
> 

Seth, can you verify?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
