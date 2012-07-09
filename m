Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D1CE66B0062
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:12:36 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so23401436pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 07:12:36 -0700 (PDT)
Date: Mon, 9 Jul 2012 23:12:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Warn about costly page allocation
Message-ID: <20120709141225.GA17314@barrios>
References: <1341801500-5798-1-git-send-email-minchan@kernel.org>
 <20120709082200.GX14154@suse.de>
 <20120709084657.GA7915@bbox>
 <jtek81$ja5$1@dough.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <jtek81$ja5$1@dough.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Cong,

On Mon, Jul 09, 2012 at 12:53:22PM +0000, Cong Wang wrote:
> On Mon, 09 Jul 2012 at 08:46 GMT, Minchan Kim <minchan@kernel.org> wrote:
> >> 
> >> WARN_ON_ONCE would tell you what is trying to satisfy the allocation.
> >
> > Do you mean that it would be better to use WARN_ON_ONCE rather than raw printk?
> > If so, I would like to insist raw printk because WARN_ON_ONCE could be disabled
> > by !CONFIG_BUG.
> > If I miss something, could you elaborate it more?
> >
> 
> Raw printk could be disabled by !CONFIG_PRINTK too, and given that:

Yes.
In such case, It is very hard to diagnose the system so at least
we enables CONFIG_PRINTK.

> 
> config PRINTK
>         default y
>         bool "Enable support for printk" if EXPERT
> 		    
> config BUG
>         bool "BUG() support" if EXPERT
>         default y
> 
> they are both configurable only when ERPERT, so we don't need to
> worry much. :)

Embedded can use CONFIG_PRINTK and !CONFIG_BUG for size optimization
and printk(pr_xxx) + dump_stack is common technic used in all over kernel
sources. Do you have any reason you don't like it?


> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
