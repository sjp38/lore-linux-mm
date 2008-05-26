Date: Mon, 26 May 2008 13:40:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] slub: record page flag overlays explicitly
In-Reply-To: <1211560402.0@pinky>
References: <exportbomb.1211560342@pinky> <1211560402.0@pinky>
Message-Id: <20080526133755.4664.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi

This patch works well on my box.
but I have one question.

>  	if (s->flags & DEBUG_DEFAULT_FLAGS) {
> -		if (!SlabDebug(page))
> -			printk(KERN_ERR "SLUB %s: SlabDebug not set "
> +		if (!PageSlubDebug(page))
> +			printk(KERN_ERR "SLUB %s: SlubDebug not set "
>  				"on slab 0x%p\n", s->name, page);
>  	} else {
> -		if (SlabDebug(page))
> -			printk(KERN_ERR "SLUB %s: SlabDebug set on "
> +		if (PageSlubDebug(page))
> +			printk(KERN_ERR "SLUB %s: SlubDebug set on "
>  				"slab 0x%p\n", s->name, page);
>  	}
>  }

Why if(SLABDEBUG) check is unnecessary?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
