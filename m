Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 833876B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 11:19:58 -0400 (EDT)
Date: Wed, 17 Apr 2013 16:08:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] swap: redirty page if page write fails on swap file
Message-ID: <20130417150837.GB1852@suse.de>
References: <516E918B.3050309@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <516E918B.3050309@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Apr 17, 2013 at 02:11:55PM +0200, Jerome Marchand wrote:
> 
> Since commit 62c230b, swap_writepage() calls direct_IO on swap files.
> However, in that case page isn't redirtied if I/O fails, and is therefore
> handled afterwards as if it has been successfully written to the swap
> file, leading to memory corruption when the page is eventually swapped
> back in.
> This patch sets the page dirty when direct_IO() fails. It fixes a memory
> corruption that happened while using swap-over-NFS.
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

Thanks Jerome. I've added Andrew to the cc and this should also be
considered a candidate for 3.8-stable.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
