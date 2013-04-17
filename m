Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id E99DD6B00A0
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 11:08:05 -0400 (EDT)
Date: Wed, 17 Apr 2013 08:07:57 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] swap: redirty page if page write fails on swap file
Message-ID: <20130417150757.GA21444@cmpxchg.org>
References: <516E918B.3050309@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <516E918B.3050309@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
