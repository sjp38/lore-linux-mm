Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 61F386B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 05:24:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so42958966wme.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 02:24:01 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id ga6si3705678wjb.152.2016.05.04.02.24.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 02:24:00 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id n129so179912591wmn.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 02:24:00 -0700 (PDT)
Date: Wed, 4 May 2016 11:23:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm/page_owner: use stackdepot to store stacktrace
Message-ID: <20160504092359.GH29978@dhcp22.suse.cz>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-7-git-send-email-iamjoonsoo.kim@lge.com>
 <20160503085356.GD28039@dhcp22.suse.cz>
 <20160504021449.GA10256@js1304-P5Q-DELUXE>
 <20160504023500.GB10256@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504023500.GB10256@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 04-05-16 11:35:00, Joonsoo Kim wrote:
[...]
> Oops... I think more deeply and change my mind. In recursion case,
> stack is consumed more than 1KB and it would be a problem. I think
> that best approach is using preallocated per cpu entry. It will also
> close recursion detection issue by paying interrupt on/off overhead.

I was thinking about per-cpu solution as well but the thing is that the
stackdepot will allocate and until you drop __GFP_DIRECT_RECLAIM then
per-cpu is not safe. I haven't checked the implamentation of
depot_save_stack but I assume it will not schedule in other places.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
