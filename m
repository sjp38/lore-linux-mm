Date: Thu, 7 Aug 2003 10:44:52 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: 2.6.0-test2-mm5
Message-ID: <20030807084451.GA858@suse.de>
References: <20030806223716.26af3255.akpm@osdl.org> <28050000.1060237907@[10.10.2.4]> <20030807000542.5cbf0a56.akpm@osdl.org> <3F320DFC.6070400@cyberone.com.au> <3F32108A.2010000@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3F32108A.2010000@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 07 2003, Nick Piggin wrote:
> --- linux-2.6/drivers/block/as-iosched.c.orig	2003-08-07 18:33:06.000000000 +1000
> +++ linux-2.6/drivers/block/as-iosched.c	2003-08-07 18:36:03.000000000 +1000
> @@ -1198,8 +1198,10 @@ static int as_dispatch_request(struct as
>  			 */
>  			goto dispatch_writes;
>  
> - 		if (ad->batch_data_dir == REQ_ASYNC)
> + 		if (ad->batch_data_dir == REQ_ASYNC) {
> +			WARN_ON(ad->new_batch || ad->changed_batch);

combining debug checks like this is generally a bad idea imho, since you
don't know which of them triggered...

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
