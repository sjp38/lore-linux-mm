Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9ACB36B0095
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 19:03:37 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so22088420pbc.21
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:03:37 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ot3si42568261pac.108.2013.12.03.16.03.35
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 16:03:36 -0800 (PST)
Date: Wed, 4 Dec 2013 09:04:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v8 4/4] zram: promote zram from staging
Message-ID: <20131204000453.GA14100@bbox>
References: <1385355978-6386-1-git-send-email-minchan@kernel.org>
 <1385355978-6386-5-git-send-email-minchan@kernel.org>
 <529DC580.9000008@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <529DC580.9000008@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Luigi Semenzato <semenzato@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>

Hello Jerome,

On Tue, Dec 03, 2013 at 12:50:24PM +0100, Jerome Marchand wrote:
> On 11/25/2013 06:06 AM, Minchan Kim wrote:
> > Zram has lived in staging for a LONG LONG time and have been
> > fixed/improved by many contributors so code is clean and stable now.
> > Of course, there are lots of product using zram in real practice.
> > 
> > The major TV companys have used zram as swap since two years ago
> > and recently our production team released android smart phone with zram
> > which is used as swap, too and recently Android Kitkat start to use zram
> > for small memory smart phone.  And there was a report Google released
> > their ChromeOS with zram, too and cyanogenmod have been used zram
> > long time ago. And I heard some disto have used zram block device
> > for tmpfs. In addition, I saw many report from many other peoples.
> > For example, Lubuntu start to use it.
> > 
> > The benefit of zram is very clear. With my experience, one of the benefit
> > was to remove jitter of video application with backgroud memory pressure.
> > It would be effect of efficient memory usage by compression but more issue
> > is whether swap is there or not in the system. Recent mobile platforms have
> > used JAVA so there are many anonymous pages. But embedded system normally
> > are reluctant to use eMMC or SDCard as swap because there is wear-leveling
> > and latency issues so if we do not use swap, it means we can't reclaim
> > anoymous pages and at last, we could encounter OOM kill. :(
> > 
> > Although we have real storage as swap, it was a problem, too. Because
> > it sometime ends up making system very unresponsible caused by slow
> > swap storage performance.
> > 
> > Quote from Luigi on Google
> > "
> > Since Chrome OS was mentioned: the main reason why we don't use swap
> > to a disk (rotating or SSD) is because it doesn't degrade gracefully
> > and leads to a bad interactive experience.  Generally we prefer to
> > manage RAM at a higher level, by transparently killing and restarting
> > processes.  But we noticed that zram is fast enough to be competitive
> > with the latter, and it lets us make more efficient use of the
> > available RAM.
> > "
> > and he announced. http://www.spinics.net/lists/linux-mm/msg57717.html
> > 
> > Other uses case is to use zram for block device. Zram is block device
> > so anyone can format the block device and mount on it so some guys
> > on the internet start zram as /var/tmp.
> > http://forums.gentoo.org/viewtopic-t-838198-start-0.html
> > 
> > Let's promote zram and enhance/maintain it instead of removing.
> > 
> > Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > Acked-by: Nitin Gupta <ngupta@vflare.org>
> > Acked-by: Pekka Enberg <penberg@kernel.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/block/Kconfig           |    2 +
> >  drivers/block/Makefile          |    2 +
> >  drivers/block/zram/Kconfig      |   25 +
> >  drivers/block/zram/Makefile     |    3 +
> >  drivers/block/zram/zram.txt     |   77 +++
> 
> Shouldn't that go in Documentation/ directory?
> In Documentation/blockdev/ maybe.

Sure. I will wait more to get a review from others
and I will update it in next spin.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
