Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7561280300
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 03:42:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r7so5046242wrb.0
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 00:42:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b4si1407453wmf.154.2017.08.02.00.42.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 00:42:57 -0700 (PDT)
Date: Wed, 2 Aug 2017 09:42:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: rename global_page_state to
 global_zone_page_state
Message-ID: <20170802074255.GC2524@dhcp22.suse.cz>
References: <20170801134256.5400-1-hannes@cmpxchg.org>
 <20170801134256.5400-2-hannes@cmpxchg.org>
 <20170801140520.96835ef87fe41a448c05504b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801140520.96835ef87fe41a448c05504b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Josef Bacik <josef@toxicpanda.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 01-08-17 14:05:20, Andrew Morton wrote:
[...]
> WARNING: line over 80 characters
> #187: FILE: mm/page-writeback.c:1408:
> + * global_zone_page_state() too often. So scale it near-sqrt to the safety margin
> 
> 
> Liveable with, but the code would be quite a bit neater if we had a
> helper function for this.

I vaguely remember somebody wanted to add/consolidate a helper to
convert pages to kB as we have more of those. I wouldn't lose
sleep over "line over 80 characters" warnings in this case. Those lines
are still readable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
