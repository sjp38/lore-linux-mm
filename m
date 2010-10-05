Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39DF86B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 19:45:37 -0400 (EDT)
Date: Tue, 5 Oct 2010 16:43:00 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: OOM panics with zram
Message-ID: <20101005234300.GA14396@kroah.com>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
 <1284053081.7586.7910.camel@nimitz>
 <4CA8CE45.9040207@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA8CE45.9040207@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Oct 03, 2010 at 02:41:09PM -0400, Nitin Gupta wrote:
> Also, please do not use linux-next/mainline version of compcache. Instead
> just use version in the project repository here:
> hg clone https://compcache.googlecode.com/hg/ compcache 

What?  No, the reason we put this into the kernel was so that _everyone_
could work on it, including the original developers.  Going off and
doing development somewhere else just isn't ok.  Should I just delete
this driver from the staging tree as you don't seem to want to work with
the community at this point in time?

> This is updated much more frequently and has many more bug fixes over
> the mainline. It will also be easier to fix bugs/add features much more
> quickly in this repo rather than sending them to lkml which can take
> long time.

Yes, developing in your own sandbox can always be faster, but there is
no feedback loop.

sad,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
