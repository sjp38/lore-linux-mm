Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id DD3686B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 10:35:54 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so216006pbc.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 07:35:54 -0700 (PDT)
Date: Tue, 24 Apr 2012 07:35:49 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] drivers: staging: zcache: fix Kconfig crypto dependency
Message-ID: <20120424143549.GA3438@kroah.com>
References: <1335231230-29344-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120424022702.GA6573@kroah.com>
 <4F96AAF4.2000402@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F96AAF4.2000402@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Autif Khan <autif.mlist@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Tue, Apr 24, 2012 at 08:30:28AM -0500, Seth Jennings wrote:
> On 04/23/2012 09:27 PM, Greg Kroah-Hartman wrote:
> > Ok, this fixes one of the build problems reported, what about the other
> > one?
> 
> Both problems that I heard about were caused by same issue;
> the issue fixed in this patch.
> 
> ZSMALLOC=m was only allowed because CRYPTO=m was allowed.
> This patch requires CRYPTO=y, which also requires ZSMALLOC=y
> when ZCACHE=y.
> 
> https://lkml.org/lkml/2012/4/19/588
> 
> https://lkml.org/lkml/2012/4/23/481

Ah, ok, I didn't realize that, thanks for letting me know, I'll queue
this up later today.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
