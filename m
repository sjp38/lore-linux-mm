Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23CD66B0038
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 04:53:41 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so44047961wmd.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 01:53:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3si1322874wrb.153.2017.01.26.01.53.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 01:53:40 -0800 (PST)
Date: Thu, 26 Jan 2017 09:52:25 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/5] mm: vmscan: scan dirty pages even in laptop mode
Message-ID: <20170126095225.kvv546uvofie25ym@suse.de>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 01:16:37PM -0500, Johannes Weiner wrote:
> We have an elaborate dirty/writeback throttling mechanism inside the
> reclaim scanner, but for that to work the pages have to go through
> shrink_page_list() and get counted for what they are. Otherwise, we
> mess up the LRU order and don't match reclaim speed to writeback.
> 
> Especially during deactivation, there is never a reason to skip dirty
> pages; nothing is even trying to write them out from there. Don't mess
> up the LRU order for nothing, shuffle these pages along.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
