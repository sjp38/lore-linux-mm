Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 308216B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 18:13:38 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so1709024pad.24
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 15:13:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ey5si16985713pab.74.2014.01.13.15.13.36
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 15:13:36 -0800 (PST)
Date: Mon, 13 Jan 2014 15:13:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] mm: vmscan: move call to shrink_slab() to
 shrink_zones()
Message-Id: <20140113151334.996da9f248db297faeed1ed1@linux-foundation.org>
In-Reply-To: <1e31dd389002eca2533e6b112a774855426b1703.1389443272.git.vdavydov@parallels.com>
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com>
	<1e31dd389002eca2533e6b112a774855426b1703.1389443272.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>

On Sat, 11 Jan 2014 16:36:34 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> This reduces the indentation level of do_try_to_free_pages() and removes
> extra loop over all eligible zones counting the number of on-LRU pages.

So this should cause no functional change, yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
