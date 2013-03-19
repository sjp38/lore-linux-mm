Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 1C22E6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 20:22:44 -0400 (EDT)
Received: by mail-da0-f52.google.com with SMTP id f10so1648198dak.25
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 17:22:43 -0700 (PDT)
Date: Mon, 18 Mar 2013 17:23:59 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 0/5] zcache: Support zero-filled pages more efficiently
Message-ID: <20130319002359.GA29441@kroah.com>
References: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 10:34:15AM +0800, Wanpeng Li wrote:
> Changelog:
>  v2 -> v3:
>   * increment/decrement zcache_[eph|pers]_zpages for zero-filled pages, spotted by Dan 
>   * replace "zero" or "zero page" by "zero_filled_page", spotted by Dan
>  v1 -> v2:
>   * avoid changing tmem.[ch] entirely, spotted by Dan.
>   * don't accumulate [eph|pers]pageframe and [eph|pers]zpages for 
>     zero-filled pages, spotted by Dan
>   * cleanup TODO list
>   * add Dan Acked-by.

In the future, please make the subject: lines have "staging: zcache:" in
them, so I don't have to edit them by hand.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
