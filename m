Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 932406B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:30:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so56115946wmr.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:30:56 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id k2si626646wjs.201.2016.07.18.04.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 04:30:55 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so12230541wme.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:30:55 -0700 (PDT)
Date: Mon, 18 Jul 2016 13:30:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/8] compaction-related cleanups v4
Message-ID: <20160718113054.GI22671@dhcp22.suse.cz>
References: <20160718112302.27381-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160718112302.27381-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Mon 18-07-16 13:22:54, Vlastimil Babka wrote:
> Hi,
> 
> this is the splitted-off first part of my "make direct compaction more
> deterministic" series [1], rebased on mmotm-2016-07-13-16-09-18. For the whole
> series it's probably too late for 4.8 given some unresolved feedback, but I
> hope this part could go in as it was stable for quite some time.
> 
> At the very least, the first patch really shouldn't wait any longer.

I think the rest looks also good to go. It makes the code more readable,
removes some hacks and...

>  11 files changed, 164 insertions(+), 233 deletions(-)

looks promissing as well.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
