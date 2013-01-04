Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 878636B004D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 15:51:30 -0500 (EST)
Received: by mail-da0-f51.google.com with SMTP id i30so7617033dad.38
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 12:51:29 -0800 (PST)
Date: Fri, 4 Jan 2013 12:51:40 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC/PATCH] drivers/staging/zcache: remove (old) zcache
Message-ID: <20130104205140.GB8365@kroah.com>
References: <ea7e4623-0983-4b1d-9d0d-8a523669adca@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea7e4623-0983-4b1d-9d0d-8a523669adca@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On Fri, Jan 04, 2013 at 11:53:37AM -0800, Dan Magenheimer wrote:
> Since Seth Jennings has moved on to zswap [1], I believe further
> effort on the older version of zcache has been abandoned.
> Unless there are objections, I can submit a patch to
> Greg to remove drivers/staging/zcache and, at some point,
> follow up with a patch to re-invert drivers/staging/ramster
> so that the newer version of zcache (aka zcache2) becomes
> drivers/staging/zcache, with ramster as a subdirectory.
> 
> If I've missed anyone on the cc list who possibly cares about
> the old version of zcache, kindly forward.
> 
> Greg, assuming no objections, do you want an official patch,
> i.e. removing each individual line of each file in
> drivers/staging/zcache?  Or will you just do a git rm?
> If the latter and you need a SOB, I am the original author so:
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com> 

I'll just delete it and add your signed-off-by to the patch that does
it.  Unless someone speaks up in the next week or so, consider it
removed.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
