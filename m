Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id B6BBB6B002B
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 21:58:49 -0400 (EDT)
Date: Wed, 31 Oct 2012 11:04:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 0/3] zram/zsmalloc promotion
Message-ID: <20121031020443.GP15767@bbox>
References: <1351501009-15111-1-git-send-email-minchan@kernel.org>
 <20121031010642.GN15767@bbox>
 <20121031014209.GB2672@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121031014209.GB2672@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jens Axboe <axboe@kernel.dk>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Greg,

On Tue, Oct 30, 2012 at 06:42:09PM -0700, Greg Kroah-Hartman wrote:
> On Wed, Oct 31, 2012 at 10:06:42AM +0900, Minchan Kim wrote:
> > Thanks all,
> > 
> > At last, everybody who contributes to zsmalloc want to put it under /lib.
> > 
> > Greg,
> > What should I do for promoting this dragging patchset?
> 
> You need to get the -mm developers to agree that this is something that
> is worth accepting.  I have yet to see any compeling argument why this

I'm one of mm developers. :)
Yes. I hope Andrew have a time to take a look.

> even needs to be in the kernel in the first place.

Confused. what do you mean "this"? "zsmalloc" or "zram" or "both"?
If you mean "zsmalloc", I guess there were some lengthy thread about
"why we need a new another allocator". Unfortunately, I didn't follow it
at that time. Nitin, Pekka, Could you point out that thread? or summarize
the result.

> 
> I'm not moving this anywhere until you get their acceptance.

I understand you.

It's one of problem in current mm mailing list.
As you know, many mm guys works for server, not embedded so they don't have
big interest about embedded feature so prioirty of the feature was always
low. CMA proved it and next turn is zram. Even new-comer in mm is few so
review bandwidth is always low, too. :(

How can I poke them?
The only thing I can do is just (wait, repost) * 5?
Sigh. :(

> 
> greg k-h
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
