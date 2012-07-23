Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 3EE1F6B005A
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 20:12:56 -0400 (EDT)
Date: Mon, 23 Jul 2012 09:13:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/3] zsmalloc: prevent mappping in interrupt context
Message-ID: <20120723001311.GB4037@bbox>
References: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1342630556-28686-2-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342630556-28686-2-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Wed, Jul 18, 2012 at 11:55:55AM -0500, Seth Jennings wrote:
> Because we use per-cpu mapping areas shared among the
> pools/users, we can't allow mapping in interrupt context
> because it can corrupt another users mappings.
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
