Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D7AFC6B002B
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 06:41:58 -0400 (EDT)
Date: Wed, 15 Aug 2012 05:38:28 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120815093828.GB2865@phenom.dumpdata.com>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <5021795A.5000509@linux.vnet.ibm.com>
 <5024067F.3010602@linux.vnet.ibm.com>
 <2e9ccb4f-1339-4c26-88dd-ea294b022127@default>
 <50254F69.2000409@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50254F69.2000409@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Kurt Hackel <kurt.hackel@oracle.com>

On Fri, Aug 10, 2012 at 01:14:01PM -0500, Seth Jennings wrote:
> On 08/09/2012 03:20 PM, Dan Magenheimer wrote
> > I also wonder if you have anything else unusual in your
> > test setup, such as a fast swap disk (mine is a partition
> > on the same rotating disk as source and target of the kernel build,
> > the default install for a RHEL6 system)?
> 
> I'm using a normal SATA HDD with two partitions, one for
> swap and the other an ext3 filesystem with the kernel source.
> 
> > Or have you disabled cleancache?
> 
> Yes, I _did_ disable cleancache.  I could see where having
> cleancache enabled could explain the difference in results.

Why did you disable the cleancache? Having both (cleancache
to compress fs data) and frontswap (to compress swap data) is the
goal - while you turned one of its sources off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
