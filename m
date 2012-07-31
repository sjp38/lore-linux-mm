Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 292376B005D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 11:40:40 -0400 (EDT)
Date: Tue, 31 Jul 2012 11:31:33 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 3/4] drivers: add memory management driver class
Message-ID: <20120731153133.GN4789@phenom.dumpdata.com>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1343413117-1989-4-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343413117-1989-4-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Fri, Jul 27, 2012 at 01:18:36PM -0500, Seth Jennings wrote:
> This patchset creates a new driver class under drivers/ for
> memory management related drivers, like zcache.

I was going back and forth with Dan whether it should be in mm/
or in drivers/mm.
> 
> This driver class would be for drivers that don't actually enabled
> a hardware device, but rather augment the memory manager in some
> way.
> 
> In-tree candidates for this driver class are zcache, zram, and
> lowmemorykiller, both in staging.

But with some many (well, three of them) I think sticking them in
drviers/mm makes more sense.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/Kconfig    |    2 ++
>  drivers/Makefile   |    1 +
>  drivers/mm/Kconfig |    3 +++
>  3 files changed, 6 insertions(+)
>  create mode 100644 drivers/mm/Kconfig
> 
> diff --git a/drivers/Kconfig b/drivers/Kconfig
> index ece958d..67fe7bd 100644
> --- a/drivers/Kconfig
> +++ b/drivers/Kconfig
> @@ -152,4 +152,6 @@ source "drivers/vme/Kconfig"
>  
>  source "drivers/pwm/Kconfig"
>  
> +source "drivers/mm/Kconfig"
> +
>  endmenu
> diff --git a/drivers/Makefile b/drivers/Makefile
> index 5b42184..121742e 100644
> --- a/drivers/Makefile
> +++ b/drivers/Makefile
> @@ -139,3 +139,4 @@ obj-$(CONFIG_EXTCON)		+= extcon/
>  obj-$(CONFIG_MEMORY)		+= memory/
>  obj-$(CONFIG_IIO)		+= iio/
>  obj-$(CONFIG_VME_BUS)		+= vme/
> +obj-$(CONFIG_MM_DRIVERS)	+= mm/
> diff --git a/drivers/mm/Kconfig b/drivers/mm/Kconfig
> new file mode 100644
> index 0000000..e5b3743
> --- /dev/null
> +++ b/drivers/mm/Kconfig
> @@ -0,0 +1,3 @@
> +menu "Memory management drivers"
> +
> +endmenu
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
