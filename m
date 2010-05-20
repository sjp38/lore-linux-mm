Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E00356008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 21:00:36 -0400 (EDT)
Date: Thu, 20 May 2010 09:00:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at
 first
Message-ID: <20100520010032.GC4089@localhost>
References: <20100519174327.9591.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100519174327.9591.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Li, Shaohua" <shaohua.li@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

The preceding comment "they need to go on the active_anon lru below"
also needs update.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
