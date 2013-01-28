Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 9B3826B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 22:44:05 -0500 (EST)
Date: Mon, 28 Jan 2013 12:44:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/4] staging: zsmalloc: make CLASS_DELTA relative to
 PAGE_SIZE
Message-ID: <20130128034404.GD3321@blaptop>
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359135978-15119-5-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359135978-15119-5-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Fri, Jan 25, 2013 at 11:46:18AM -0600, Seth Jennings wrote:
> Right now ZS_SIZE_CLASS_DELTA is hardcoded to be 16.  This
> creates 254 classes for systems with 4k pages. However, on
> PPC64 with 64k pages, it creates 4095 classes which is far
> too many.
> 
> This patch makes ZS_SIZE_CLASS_DELTA relative to PAGE_SIZE
> so that regardless of the page size, there will be the same
> number of classes.
> 
> Acked-by: Nitin Gupta <ngupta@vflare.org>
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
