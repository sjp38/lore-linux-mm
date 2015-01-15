Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8B49C6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 02:56:26 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so15962506pab.6
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 23:56:26 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id oc17si938454pdb.97.2015.01.14.23.56.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 23:56:24 -0800 (PST)
Date: Thu, 15 Jan 2015 10:56:10 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm] vmscan: move reclaim_state handling to shrink_slab
Message-ID: <20150115075610.GF11264@esperanza>
References: <1421243736-21367-1-git-send-email-vdavydov@parallels.com>
 <20150114153449.038bc61b1bd6fc262f9cea01@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150114153449.038bc61b1bd6fc262f9cea01@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 14, 2015 at 03:34:49PM -0800, Andrew Morton wrote:
> On Wed, 14 Jan 2015 16:55:36 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> > This patch also makes shrink_slab() return the number of reclaimed slab
> > pages (obtained from reclaim_state) instead of the number of reclaimed
> > objects, because the latter is not of much use - it was only checked by
> > drop_slab() to decide whether it should continue reclaim or abort. The
> > number of reclaimed pages is more appropriate, because it also can be
> > used by shrink_zone() to accumulate scan_control->nr_reclaimed.
> 
> Not sure that this is a good change.  If shrink_slab() managed to free
> some objects but didn't free any pages then that's a good sign that
> additional calls to shrink_slab() *will* free some pages.  With this
> change, drop_slab_node() can give up too early.

Fair enough. We'd better leave the return value intact then. I think we
should add an additional argument to add the number of reclaimed slab
pages to, as I intended to do initially. Will resend.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
