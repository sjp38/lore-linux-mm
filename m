Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
From: Nigel Cunningham <ncunningham@linuxmail.org>
Reply-To: ncunningham@linuxmail.org
In-Reply-To: <41E8F7F7.1010908@yahoo.com.au>
References: <20050113061401.GA7404@blackham.com.au>
	 <41E61479.5040704@yahoo.com.au> <20050113085626.GA5374@blackham.com.au>
	 <20050113101426.GA4883@blackham.com.au>  <41E8ED89.8090306@yahoo.com.au>
	 <1105785254.13918.4.camel@desktop.cunninghams>
	 <41E8F313.4030102@yahoo.com.au>
	 <1105786115.13918.9.camel@desktop.cunninghams>
	 <41E8F7F7.1010908@yahoo.com.au>
Content-Type: text/plain
Message-Id: <1105788761.14706.0.camel@desktop.cunninghams>
Mime-Version: 1.0
Date: Sat, 15 Jan 2005 22:32:41 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Bernard Blackham <bernard@blackham.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Sat, 2005-01-15 at 22:01, Nick Piggin wrote:
> I wouldn't suspect so, but we'll see... How do I get my hands on
> suspend2?

http://softwaresuspend.berlios.de

Regards,

Nigel

> Also, Bernard, can you try running with the following patch and
> see what output it gives when you reproduce the problem?
> 
> Thanks a lot,
> Nick
> 
> ______________________________________________________________________
> Index: linux-2.6/mm/vmscan.c
> ===================================================================
> --- linux-2.6.orig/mm/vmscan.c	2005-01-15 21:54:24.579134294 +1100
> +++ linux-2.6/mm/vmscan.c	2005-01-15 21:56:51.719355929 +1100
> @@ -1182,6 +1182,7 @@
>  		}
>  		finish_wait(&pgdat->kswapd_wait, &wait);
>  
> +		printk("kswapd: balance_pgdat, order = %lu\n", order);
>  		balance_pgdat(pgdat, 0, order);
>  	}
>  	return 0;
-- 
Nigel Cunningham
Software Engineer, Canberra, Australia
http://www.cyclades.com

Ph: +61 (2) 6292 8028      Mob: +61 (417) 100 574

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
