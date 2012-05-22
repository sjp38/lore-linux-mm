Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 751A96B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 14:37:55 -0400 (EDT)
Date: Tue, 22 May 2012 14:31:19 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] zsmalloc: use unsigned long instead of void *
Message-ID: <20120522183119.GA24107@phenom.dumpdata.com>
References: <1337567013-4741-1-git-send-email-minchan@kernel.org>
 <4FBA4EE2.8050308@linux.vnet.ibm.com>
 <4FBB97B2.6050408@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FBB97B2.6050408@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>

On Tue, May 22, 2012 at 08:42:10AM -0500, Seth Jennings wrote:
> On 05/21/2012 09:19 AM, Seth Jennings wrote:
> 
> > On 05/20/2012 09:23 PM, Minchan Kim wrote:
> > 
> >> We should use unsigned long as handle instead of void * to avoid any
> >> confusion. Without this, users may just treat zs_malloc return value as
> >> a pointer and try to deference it.
> > 
> > 
> > I wouldn't have agreed with you about the need for this change as people
> > should understand a void * to be the address of some data with unknown
> > structure.
> > 
> > However, I recently discussed with Dan regarding his RAMster project
> > where he assumed that the void * would be an address, and as such,
> > 4-byte aligned.  So he has masked two bits into the two LSBs of the
> > handle for RAMster, which doesn't work with zsmalloc since the handle is
> > not an address.
> > 
> > So really we do need to convey as explicitly as possible to the user
> > that the handle is an _opaque_ value about which no assumption can be made.
> 
> 
> Wasn't really clear here.  All that to say, I think we do need this patch.

That sounds like an Acked-by ?

> 
> Thanks,
> Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
