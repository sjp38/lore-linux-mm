Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0700B6B027B
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:28:18 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z34so13045606wrz.0
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:28:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h20si4823614eda.203.2017.11.15.06.28.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 06:28:16 -0800 (PST)
Date: Wed, 15 Nov 2017 15:28:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
 <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yasu.isimatu@gmail.com, koki.sanagi@us.fujitsu.com

On Wed 15-11-17 14:13:29, Mel Gorman wrote:
[...]
> I doubt anyone well. Even the original reporter appeared to pick that
> particular value just to trigger the OOM.

Then why do we care at all? The trace buffer size can be configured from
the userspace if it is not sufficiently large IIRC.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
