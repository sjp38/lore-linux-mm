Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id AE8C66B005A
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 20:11:08 -0400 (EDT)
Date: Mon, 23 Jul 2012 09:11:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] zsmalloc: s/firstpage/page in new copy map funcs
Message-ID: <20120723001123.GA4037@bbox>
References: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Wed, Jul 18, 2012 at 11:55:54AM -0500, Seth Jennings wrote:
> firstpage already has precedent and meaning the first page
> of a zspage.  In the case of the copy mapping functions,
> it is the first of a pair of pages needing to be mapped.
> 
> This patch just renames the firstpage argument to "page" to
> avoid confusion.
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
