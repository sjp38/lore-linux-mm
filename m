Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 866776B004D
	for <linux-mm@kvack.org>; Tue, 26 May 2009 04:35:33 -0400 (EDT)
Date: Tue, 26 May 2009 10:35:38 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH][mmtom] clean up once printk routine
Message-ID: <20090526083538.GA29563@elf.ucw.cz>
References: <20090526135733.3c38f758.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090526135733.3c38f758.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, Randy Dunlap <randy.dunlap@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Dominik Brodowski <linux@dominikbrodowski.net>, Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi!

> Yes. There are also some places to be able to use printk_once().
> Are there any place I missed ?
> 
> == CUT HERE ==
> 
> There are some places to be able to use printk_once instead of hard coding.
> 
> It will help code readability and maintenance.
> This patch doesn't change function's behavior.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> CC: Dominik Brodowski <linux@dominikbrodowski.net>
> CC: David S. Miller <davem@davemloft.net>
> CC: Ingo Molnar <mingo@elte.hu>
> ---
>  arch/x86/kernel/cpu/common.c  |    8 ++------
>  drivers/net/3c515.c           |    7 ++-----
>  drivers/pcmcia/pcmcia_ioctl.c |    9 +++------
>  3 files changed, 7 insertions(+), 17 deletions(-)
> 
> diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
> index 82bec86..dc0f694 100644
> --- a/arch/x86/kernel/cpu/common.c
> +++ b/arch/x86/kernel/cpu/common.c
> @@ -496,13 +496,9 @@ static void __cpuinit get_cpu_vendor(struct cpuinfo_x86 *c)
>  		}
>  	}
>  
> -	if (!printed) {
> -		printed++;
> -		printk(KERN_ERR
> +	printk_once(KERN_ERR
>  		    "CPU: vendor_id '%s' unknown, using generic init.\n", v);
> -
> -		printk(KERN_ERR "CPU: Your system may be unstable.\n");
> -	}
> +	printk_once(KERN_ERR "CPU: Your system may be unstable.\n");
>

You should delete the variable, right?

Plus, the code now uses two variables instead of one.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
