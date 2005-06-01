Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j51KtPAh022768
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 16:55:25 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j51KtOtR202406
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 16:55:24 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j51KtNjg017646
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 16:55:24 -0400
Message-ID: <429E20B6.2000907@austin.ibm.com>
Date: Wed, 01 Jun 2005 15:55:18 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <20050531112048.D2511E57A@skynet.csn.ul.ie>
In-Reply-To: <20050531112048.D2511E57A@skynet.csn.ul.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> -		struct free_area *area;
>  		struct page *buddy;
> -
> +		

...

>  	}
> +
>  	spin_unlock_irqrestore(&zone->lock, flags);
> -	return allocated;
> +	return count - allocated;
>  }
>  
> +
> +

Other than the very minor whitespace changes above I have nothing bad to 
say about this patch.  I think it is about time to pick in up in -mm for 
wider testing.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
