Subject: Re: 2.6.0-mm2
From: Dax Kelson <dax@gurulabs.com>
In-Reply-To: <20031229013223.75c531ed.akpm@osdl.org>
References: <20031229013223.75c531ed.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1072722682.15739.2.camel@mentor.gurulabs.com>
Mime-Version: 1.0
Date: Mon, 29 Dec 2003 11:31:22 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-12-29 at 02:32, Andrew Morton wrote:

> Changes since 2.6.0-mm1:

> +remove-CardServices-from-ide-cs.patch
> +remove-CardServices-from-drivers-net-wireless.patch
> +remove-CardServices-from-drivers-serial.patch
> +remove-CardServices-from-drivers-serial-fix.patch
> +remove-CardServices-final.patch
> 
>  Complete the removal of the usage of the CardServices API from drivers. 
>  It's a bit late for this, but apparantly the varargs usage in the API cannot
>  work correctly on x86_64 (at least).

I'm on a P4 laptop, I just compiled up 2.6.0-mm2 (to get the mouse
fixes) and a make modules_install showed:

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.6.0-mm2; fi
WARNING: /lib/modules/2.6.0-mm2/kernel/drivers/net/typhoon.ko needs unknown symbol direct_csum_partial_copy_generic
WARNING: /lib/modules/2.6.0-mm2/kernel/drivers/net/wireless/wavelan_cs.ko needs unknown symbol CardServices
WARNING: /lib/modules/2.6.0-mm2/kernel/drivers/net/pcmcia/axnet_cs.ko needs unknown symbol CardServices

I need wavelan_cs to use my laptop.

Dax Kelson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
