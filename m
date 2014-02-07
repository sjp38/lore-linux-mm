Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 51E776B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 11:21:36 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id x13so2383103wgg.33
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 08:21:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5si2546563wjw.76.2014.02.07.08.21.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 08:21:34 -0800 (PST)
Date: Fri, 7 Feb 2014 16:21:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: fix page leak at nfs_symlink()
Message-ID: <20140207162131.GY6732@suse.de>
References: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com, jstancek@redhat.com, jlayton@redhat.com, riel@redhat.com, linux-nfs@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Feb 07, 2014 at 01:19:54PM -0200, Rafael Aquini wrote:
> Changes committed by "a0b8cab3 mm: remove lru parameter from
> __pagevec_lru_add and remove parts of pagevec API" have introduced
> a call to add_to_page_cache_lru() which causes a leak in nfs_symlink() 
> as now the page gets an extra refcount that is not dropped.
> 
> Jan Stancek observed and reported the leak effect while running test8 from
> Connectathon Testsuite. After several iterations over the test case,
> which creates several symlinks on a NFS mountpoint, the test system was
> quickly getting into an out-of-memory scenario.
> 
> This patch fixes the page leak by dropping that extra refcount 
> add_to_page_cache_lru() is grabbing. 
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

Thanks.

Acked-by: Mel Gorman <mgorman@suse.de>

It should be cc'd for stable for 3.11 and later kernels.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
