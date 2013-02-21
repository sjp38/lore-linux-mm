Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3346C6B002F
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 04:35:41 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fb11so4608913pad.14
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 01:35:40 -0800 (PST)
Date: Thu, 21 Feb 2013 17:35:27 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 1/4 v3]swap: change block allocation algorithm for SSD
Message-ID: <20130221093527.GA892@kernel.org>
References: <20130221021710.GA32580@kernel.org>
 <CAH9JG2XmbeNgVmd1gMkOxsa3v6J9pOZed6CYXUeSaiyLhTnMJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH9JG2XmbeNgVmd1gMkOxsa3v6J9pOZed6CYXUeSaiyLhTnMJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org

On Thu, Feb 21, 2013 at 05:13:35PM +0900, Kyungmin Park wrote:
> Hi,
> 
> It's not related topic with this patch, but now I'm integrating with
> zswap with this patch but zswap uses each own writeback codes so it
> can't use this cluster concept.
> 
> I'm still can't find proper approaches to integrate zswap (+writeback)
> with this concept.
> 
> Do you have any ideas or plan to work with zswap?

I didn't look at zswap. At first glance, when zswap fallbacks to writeback, it
will make swap very sparse (so cause bad IO pattern), since some pages are
compressed, some not. Is this the problem you are trying to solve? This should
exist without my patch too. Sorry, I have no idea. I'm afraid zswap need manage
the swap partion by itself.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
