Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 52DFA6B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 20:56:01 -0400 (EDT)
Date: Tue, 21 Aug 2012 09:56:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/7] zram/zsmalloc promotion
Message-ID: <20120821005617.GA14280@bbox>
References: <1344406340-14128-1-git-send-email-minchan@kernel.org>
 <20120814023530.GA9787@kroah.com>
 <20120814062246.GB31621@bbox>
 <502DDB0E.8070001@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502DDB0E.8070001@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, axboe@kernel.dk
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On Thu, Aug 16, 2012 at 10:47:58PM -0700, Nitin Gupta wrote:
> On 08/13/2012 11:22 PM, Minchan Kim wrote:
> > Hi Greg,
> > 
> > On Mon, Aug 13, 2012 at 07:35:30PM -0700, Greg Kroah-Hartman wrote:
> >> On Wed, Aug 08, 2012 at 03:12:13PM +0900, Minchan Kim wrote:
> >>> This patchset promotes zram/zsmalloc from staging.
> >>> Both are very clean and zram is used by many embedded product
> >>> for a long time.
> >>>
> >>> [1-3] are patches not merged into linux-next yet but needed
> >>> it as base for [4-5] which promotes zsmalloc.
> >>> Greg, if you merged [1-3] already, skip them.
> >>
> >> I've applied 1-3 and now 4, but that's it, I can't apply the rest
> > 
> > Thanks!
> > 
> >> without getting acks from the -mm maintainers, sorry.  Please work with
> > 
> > Nitin suggested zsmalloc could be in /lib or /zram out of /mm but I want
> > to confirm it from akpm so let's wait his opinion.
> > 
> 
> akpm, please?

To Nitin
Now both zram/zcache uses zsmalloc so I think second place is under /lib than
/zram if we really want to put it out of /mm but my preference is still
under /mm. If akpm don't oppose, I will do.
(Let's not consider removal of zsmalloc in zcache at the moment because
it's just Dan's trial and it's not realized yet. It's very twisted problem
and I don't expect it will finish soon :( )

To akpm,

I would like to put zsmalloc under /mm because it uses a few field of struct
page freely. IIRC, you pointed out, too. What do you think about it?
If you don't want, I will put zsmalloc under /lib.

To Jens,

I would like to put zram under driver/blocks.
Can I get your Ack?

> 
> > Anyway, another question. zram would be under driver/blocks.
> > Do I need ACK from Jens for that?
> > 
> 
> Added Jens to CC list.
> 
> Thanks,
> Nitin
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
