Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id AB6D46B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 12:23:40 -0400 (EDT)
Received: by ied10 with SMTP id 10so2411009ied.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 09:23:39 -0700 (PDT)
Message-ID: <1348676615.2552.5.camel@ayu>
Subject: Re: [PATCH 3/3] zram: select ZSMALLOC when ZRAM is configured
From: Calvin Walton <calvin.walton@kepstin.ca>
Date: Wed, 26 Sep 2012 12:23:35 -0400
In-Reply-To: <20120926161539.GA30132@kroah.com>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
	 <1348649419-16494-4-git-send-email-minchan@kernel.org>
	 <20120926161539.GA30132@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Jens Axboe <axboe@kernel.dk>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2012-09-26 at 09:15 -0700, Greg Kroah-Hartman wrote:
> On Wed, Sep 26, 2012 at 05:50:19PM +0900, Minchan Kim wrote:
> > At the monent, we can configure zram in driver/block once zsmalloc
> > in /lib menu is configured firstly. It's not convenient.
> > 
> > User can configure zram in driver/block regardless of zsmalloc enabling
> > by this patch.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/block/zram/Kconfig |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
> > index be5abe8..ee23a86 100644
> > --- a/drivers/block/zram/Kconfig
> > +++ b/drivers/block/zram/Kconfig
> > @@ -1,6 +1,7 @@
> >  config ZRAM
> >  	tristate "Compressed RAM block device support"
> > -	depends on BLOCK && SYSFS && ZSMALLOC
> > +	depends on BLOCK && SYSFS
> > +	select ZSMALLOC
> 
> As ZSMALLOC is dependant on CONFIG_STAGING, this isn't going to work at
> all, sorry.

Perhaps you missed [PATCH 1/3] zsmalloc: promote to lib/ ? The first
patch in this series moves zsmalloc out of the staging directory, and
removes the dependency on CONFIG_STAGING.

-- 
Calvin Walton <calvin.walton@kepstin.ca>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
