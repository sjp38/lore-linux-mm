Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 3BB7C6B006E
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 21:41:12 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so650635pad.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 18:41:11 -0700 (PDT)
Date: Tue, 30 Oct 2012 18:42:09 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 0/3] zram/zsmalloc promotion
Message-ID: <20121031014209.GB2672@kroah.com>
References: <1351501009-15111-1-git-send-email-minchan@kernel.org>
 <20121031010642.GN15767@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121031010642.GN15767@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jens Axboe <axboe@kernel.dk>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 31, 2012 at 10:06:42AM +0900, Minchan Kim wrote:
> Thanks all,
> 
> At last, everybody who contributes to zsmalloc want to put it under /lib.
> 
> Greg,
> What should I do for promoting this dragging patchset?

You need to get the -mm developers to agree that this is something that
is worth accepting.  I have yet to see any compeling argument why this
even needs to be in the kernel in the first place.

I'm not moving this anywhere until you get their acceptance.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
