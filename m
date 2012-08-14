Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 44F816B0068
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 22:35:36 -0400 (EDT)
Received: by obhx4 with SMTP id x4so9794276obh.14
        for <linux-mm@kvack.org>; Mon, 13 Aug 2012 19:35:35 -0700 (PDT)
Date: Mon, 13 Aug 2012 19:35:30 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/7] zram/zsmalloc promotion
Message-ID: <20120814023530.GA9787@kroah.com>
References: <1344406340-14128-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344406340-14128-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On Wed, Aug 08, 2012 at 03:12:13PM +0900, Minchan Kim wrote:
> This patchset promotes zram/zsmalloc from staging.
> Both are very clean and zram is used by many embedded product
> for a long time.
> 
> [1-3] are patches not merged into linux-next yet but needed
> it as base for [4-5] which promotes zsmalloc.
> Greg, if you merged [1-3] already, skip them.

I've applied 1-3 and now 4, but that's it, I can't apply the rest
without getting acks from the -mm maintainers, sorry.  Please work with
them to get those acks, and then I will be glad to apply the rest (after
you resend them of course...)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
