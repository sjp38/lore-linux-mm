Date: Mon, 08 Aug 2005 13:26:03 -0700 (PDT)
Message-Id: <20050808.132603.93023622.davem@davemloft.net>
Subject: Re: [RFC 1/3] non-resident page tracking
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050808202110.744344000@jumble.boston.redhat.com>
References: <20050808201416.450491000@jumble.boston.redhat.com>
	<20050808202110.744344000@jumble.boston.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Rik van Riel <riel@redhat.com>
Date: Mon, 08 Aug 2005 16:14:17 -0400
Return-Path: <owner-linux-mm@kvack.org>
To: riel@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> @@ -359,7 +362,10 @@ struct page *read_swap_cache_async(swp_e
>  			/*
>  			 * Initiate read into locked page and return.
>  			 */
> -			lru_cache_add_active(new_page);
> +			if (activate >= 0)
> +				lru_cache_add_active(new_page);
> +			else
> +				lru_cache_add(new_page);
>  			swap_readpage(NULL, new_page);
>  			return new_page;

This change is totally unrelated to the rest of the
patch, and is not mentioned in the changelog.  Could
you explain it?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
