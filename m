Date: Wed, 30 May 2007 11:21:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Make dynamic/run-time configuration of zonelist order
 configurable
Message-Id: <20070530112119.efa977fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1180468121.5067.64.camel@localhost>
References: <1180468121.5067.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 29 May 2007 15:48:41 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 

no problem was found on my ia64 test box.

But one point..

> -#ifdef CONFIG_NUMA
> +#ifdef CONFIG_DYNAMIC_ZONELIST_ORDER
>  	{
>  		.ctl_name	= CTL_UNNUMBERED,
>  		.procname	= "numa_zonelist_order",

non-NUMA, memory-hotpluggable machine need this control ??

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
