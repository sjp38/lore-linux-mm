Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 356A46B0080
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 18:11:17 -0500 (EST)
Date: Mon, 9 Jan 2012 15:09:44 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 0/5] staging: zsmalloc: memory allocator for compressed
 pages
Message-ID: <20120109230944.GA11802@suse.de>
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon, Jan 09, 2012 at 04:51:55PM -0600, Seth Jennings wrote:
> This patchset introduces a new memory allocation library named
> zsmalloc.  zsmalloc was designed to fulfill the needs
> of users where:
>  1) Memory is constrained, preventing contiguous page allocations
>     larger than order 0 and
>  2) Allocations are all/commonly greater than half a page.

As this is submitted during the merge window, I don't have any time to
look at it until after 3.3-rc1 is out.

I'll queue it up for then.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
