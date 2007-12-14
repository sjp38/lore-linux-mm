Date: Thu, 13 Dec 2007 16:37:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
Message-Id: <20071213163726.3bb601fa.akpm@linux-foundation.org>
In-Reply-To: <4761CE88.9070406@rtr.ca>
References: <20071213185326.GQ26334@parisc-linux.org>
	<4761821F.3050602@rtr.ca>
	<20071213192633.GD10104@kernel.dk>
	<4761883A.7050908@rtr.ca>
	<476188C4.9030802@rtr.ca>
	<20071213193937.GG10104@kernel.dk>
	<47618B0B.8020203@rtr.ca>
	<20071213195350.GH10104@kernel.dk>
	<20071213200219.GI10104@kernel.dk>
	<476190BE.9010405@rtr.ca>
	<20071213200958.GK10104@kernel.dk>
	<20071213140207.111f94e2.akpm@linux-foundation.org>
	<1197584106.3154.55.camel@localhost.localdomain>
	<20071213142935.47ff19d9.akpm@linux-foundation.org>
	<4761B32A.3070201@rtr.ca>
	<4761BCB4.1060601@rtr.ca>
	<4761C8E4.2010900@rtr.ca>
	<4761CE88.9070406@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Lord <liml@rtr.ca>
Cc: James.Bottomley@HansenPartnership.com, jens.axboe@oracle.com, lkml@rtr.ca, matthew@wil.cx, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, 13 Dec 2007 19:30:00 -0500
Mark Lord <liml@rtr.ca> wrote:

> Here's the commit that causes the regression:
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -760,7 +760,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  		struct page *page = __rmqueue(zone, order, migratetype);
>  		if (unlikely(page == NULL))
>  			break;
> -		list_add_tail(&page->lru, list);
> +		list_add(&page->lru, list);

well that looks fishy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
