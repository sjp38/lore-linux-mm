Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 031236B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 11:41:22 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so117414541lfw.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 08:41:21 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id t84si15380133wmf.138.2016.07.18.08.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 08:41:20 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 4486F1C12E0
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 16:41:20 +0100 (IST)
Date: Mon, 18 Jul 2016 16:41:18 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/8] compaction-related cleanups v4
Message-ID: <20160718154118.GB10438@techsingularity.net>
References: <20160718112302.27381-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160718112302.27381-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Mon, Jul 18, 2016 at 01:22:54PM +0200, Vlastimil Babka wrote:
> Hi,
> 
> this is the splitted-off first part of my "make direct compaction more
> deterministic" series [1], rebased on mmotm-2016-07-13-16-09-18. For the whole
> series it's probably too late for 4.8 given some unresolved feedback, but I
> hope this part could go in as it was stable for quite some time.
> 
> At the very least, the first patch really shouldn't wait any longer.
> 

I read through the patches but did not have a substantial or useful
comment to make. The compaction priority stuff is interesting and while
it'll take a little getting used to, I think it's a better way of
viewing compaction in general. For the series

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
