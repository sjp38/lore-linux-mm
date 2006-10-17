Date: Tue, 17 Oct 2006 10:27:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Oct 2006 17:50:26 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> +#if ZONES_SHIFT > 0
>  		seq_printf(m,
>  			   "\n        protection: (%lu",
>  			   zone->lowmem_reserve[0]);
> @@ -563,6 +563,7 @@ static int zoneinfo_show(struct seq_file
>  		seq_printf(m,
>  			   ")"
>  			   "\n  pagesets");
> +#endif

How about defining following instead of inserting #ifdefs ?

#ifdef ZONES_SHIFT > 0
#define zone_lowmem_reserve(z, i)	((z)->lowmem_reserve[(i)])
#else
#define zone_lowmem_reserve(z, i)	(0)
#endif

and removing #if's from *.c files ? Can't this be help ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
