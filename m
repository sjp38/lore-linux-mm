Date: Thu, 22 Jan 2004 22:30:36 +0100
From: Adrian Bunk <bunk@fs.tum.de>
Subject: Re: 2.6.2-rc1-mm1
Message-ID: <20040122213036.GP6441@fs.tum.de>
References: <20040122013501.2251e65e.akpm@osdl.org> <20040122110342.A9271@infradead.org> <20040122151943.GW21151@parcelfarce.linux.theplanet.co.uk> <20040122123156.2588d0a1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040122123156.2588d0a1.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: viro@parcelfarce.linux.theplanet.co.uk, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 22, 2004 at 12:31:56PM -0800, Andrew Morton wrote:
> viro@parcelfarce.linux.theplanet.co.uk wrote:
> >
> > { raw driver stuff ]
> >
> 
> I'd be inclined to leave the raw driver as-is, frankly.  It's deprecated,
> obsolete and we should be trying to remove it from 2.7.
> 
> --- 25/drivers/char/Kconfig~raw-is-obsolete	2004-01-22 12:30:02.000000000 -0800
> +++ 25-akpm/drivers/char/Kconfig	2004-01-22 12:31:32.000000000 -0800
> @@ -961,12 +961,15 @@ config SCx200_GPIO
>  	  If compiled as a module, it will be called scx200_gpio.
>  
>  config RAW_DRIVER
> -	tristate "RAW driver (/dev/raw/rawN)"
> +	tristate "RAW driver (/dev/raw/rawN) (OBSOLETE)"
>  	help
>  	  The raw driver permits block devices to be bound to /dev/raw/rawN. 
>  	  Once bound, I/O against /dev/raw/rawN uses efficient zero-copy I/O. 
>  	  See the raw(8) manpage for more details.
>  
> +          The raw driver is deprecated and may be removed from 2.7 kernels.
> +          Applications should simply open /dev/hda with the O_DIRECT flag.
>...

Nitpicking:
  /dev/hda -> the device

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
