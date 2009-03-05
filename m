Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 92B2F6B00C0
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 08:36:58 -0500 (EST)
Date: Thu, 5 Mar 2009 21:36:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: drop_caches ...
Message-ID: <20090305133603.GA22442@localhost>
References: <200903041057.34072.M4rkusXXL@web.de> <200903041947.41542.M4rkusXXL@web.de> <20090305004850.GA6045@localhost> <200903051255.35407.M4rkusXXL@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903051255.35407.M4rkusXXL@web.de>
Sender: owner-linux-mm@kvack.org
To: Markus <M4rkusXXL@web.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lukas Hejtmanek <xhejtman@ics.muni.cz>
List-ID: <linux-mm.kvack.org>

Hi Markus,

On Thu, Mar 05, 2009 at 01:55:35PM +0200, Markus wrote:
> > Markus, you may want to try this patch, it will have better chance to figure out
> > the hidden file pages.
> > 
> > 1) apply the patch and recompile kernel with CONFIG_PROC_FILECACHE=m
> > 2) after booting:
> >         modprobe filecache
> >         cp /proc/filecache filecache-`date +'%F'`
> > 3) send us the copied file, it will list all cached files, including
> >    the normally hidden ones.
> 
> The file consists of 674 lines. If I interpret it right, "size" is the 
> filesize and "cached" the amount of the file being in cache (why can 
> this be bigger than the file?!).

          size = file size in bytes
        cached = cached pages

So it's normal that (size > cached).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
