Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 85EEC6B0025
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:01:14 -0500 (EST)
Date: Tue, 29 Jan 2013 09:01:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv3 4/6] mm: allow for outstanding swap writeback accounting
Message-ID: <20130129000113.GG4752@blaptop>
References: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359409767-30092-5-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359409767-30092-5-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, Jan 28, 2013 at 03:49:25PM -0600, Seth Jennings wrote:
> To prevent flooding the swap device with writebacks, frontswap
> backends need to count and limit the number of outstanding
> writebacks.  The incrementing of the counter can be done before
> the call to __swap_writepage().  However, the caller must receive
> a notification when the writeback completes in order to decrement
> the counter.
> 
> To achieve this functionality, this patch modifies
> __swap_writepage() to take the bio completion callback function
> as an argument.
> 
> end_swap_bio_write(), the normal bio completion function, is also
> made non-static so that code doing the accounting can call it
> after the accounting is done.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
