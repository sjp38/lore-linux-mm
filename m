Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 6DE796B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 12:29:46 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so679857pad.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 09:29:45 -0700 (PDT)
Date: Wed, 26 Sep 2012 09:29:41 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3/3] zram: select ZSMALLOC when ZRAM is configured
Message-ID: <20120926162941.GA29694@kroah.com>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
 <1348649419-16494-4-git-send-email-minchan@kernel.org>
 <20120926161539.GA30132@kroah.com>
 <1348676615.2552.5.camel@ayu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348676615.2552.5.camel@ayu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Calvin Walton <calvin.walton@kepstin.ca>
Cc: Minchan Kim <minchan@kernel.org>, Jens Axboe <axboe@kernel.dk>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 26, 2012 at 12:23:35PM -0400, Calvin Walton wrote:
> On Wed, 2012-09-26 at 09:15 -0700, Greg Kroah-Hartman wrote:
> > On Wed, Sep 26, 2012 at 05:50:19PM +0900, Minchan Kim wrote:
> > > At the monent, we can configure zram in driver/block once zsmalloc
> > > in /lib menu is configured firstly. It's not convenient.
> > > 
> > > User can configure zram in driver/block regardless of zsmalloc enabling
> > > by this patch.
> > > 
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > ---
> > >  drivers/block/zram/Kconfig |    3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
> > > index be5abe8..ee23a86 100644
> > > --- a/drivers/block/zram/Kconfig
> > > +++ b/drivers/block/zram/Kconfig
> > > @@ -1,6 +1,7 @@
> > >  config ZRAM
> > >  	tristate "Compressed RAM block device support"
> > > -	depends on BLOCK && SYSFS && ZSMALLOC
> > > +	depends on BLOCK && SYSFS
> > > +	select ZSMALLOC
> > 
> > As ZSMALLOC is dependant on CONFIG_STAGING, this isn't going to work at
> > all, sorry.
> 
> Perhaps you missed [PATCH 1/3] zsmalloc: promote to lib/ ? The first
> patch in this series moves zsmalloc out of the staging directory, and
> removes the dependency on CONFIG_STAGING.

Ah, I did, thanks.

For 3.7, it's too late to be moving stuff out of staging to the "real"
part of the kernel as 3.6 is about to be released.

Possibly, if everyone agrees with this, after 3.7 is out we can do this
for 3.8, ok?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
