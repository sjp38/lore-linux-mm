Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5C49C6B02B9
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 14:32:12 -0400 (EDT)
Received: by gwj16 with SMTP id 16so4568592gwj.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 11:32:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1281374816-904-8-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1281374816-904-8-git-send-email-ngupta@vflare.org>
Date: Mon, 9 Aug 2010 21:32:11 +0300
Message-ID: <AANLkTikwN08QsfRNwa-4=qOu8mKkGoEUHdxUC5n8u3Ve@mail.gmail.com>
Subject: Re: [PATCH 07/10] Increase compressed page size threshold
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Nitin,

On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
> Compression takes much more time than decompression. So, its quite
> wasteful in terms of both CPU cycles and memory usage to have a very
> low compressed page size threshold and thereby storing such not-so-well
> compressible pages as-is (uncompressed). So, increasing it from
> PAGE_SIZE/2 to PAGE_SIZE/8*7. A low threshold was useful when we had
> "backing swap" support where we could forward such pages to the backing
> device (applicable only when zram was used as swap disk).
>
> It is not yet configurable through sysfs but may be exported in future,
> along with threshold for average compression ratio.
>
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>

The description makes sense but lacks any real data. What kind of
workloads did you test this with? Where does it help most? How much?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
