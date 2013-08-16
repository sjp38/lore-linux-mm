Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id B14D66B0036
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 05:13:00 -0400 (EDT)
Message-ID: <520DED04.2030605@oracle.com>
Date: Fri, 16 Aug 2013 17:12:36 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
References: <1376459736-7384-1-git-send-email-minchan@kernel.org> <20130814174050.GN2296@suse.de> <20130814185820.GA2753@gmail.com> <20130815171250.GA2296@suse.de> <20130816042641.GA2893@gmail.com> <20130816083347.GD2296@suse.de>
In-Reply-To: <20130816083347.GD2296@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

Hi Mel,

On 08/16/2013 04:33 PM, Mel Gorman wrote:
> 
> I already said I recognise it has a large number of users in the field
> and users count a lot more than me complaining. If it gets promoted then
> I expect it will be on those grounds.
> 
> My position is that I think it's a bad idea because it is clear there is no
> plan or intention of ever brining zram and zswap together. Instead we are
> to have two features providing similar functionality with zram diverging
> further from zswap.  Ultimately I believe this will increase maintenance
> headaches. It'll get even more entertaining if/when someone ever tries
> to reimplement zcache although since Dan left I do not believe anyone is
> planning to try. I will not be acking this series but there many be enough

I already reimplemented zcache based on mm/zbud.c.
http://thread.gmane.org/gmane.linux.kernel.mm/104824

I'll pay more attention to the problems of zswap as you mentioned.

> developers that are actually willing to maintain a duel zram/zswap mess
> to make it happen anyway.
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
