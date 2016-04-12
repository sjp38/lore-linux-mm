Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 199AC6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 04:03:52 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id l6so176596107wml.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 01:03:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 194si4225575wmx.103.2016.04.12.01.03.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 01:03:50 -0700 (PDT)
Subject: Re: mmotm woes, mainly compaction
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570CABE3.4070404@suse.cz>
Date: Tue, 12 Apr 2016 10:03:47 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/12/2016 09:18 AM, Hugh Dickins wrote:
> 2. Fix crash in get_pfnblock_flags_mask() from suitable_migration_target()
>     from isolate_freepages(): there's a case when that "block_start_pfn -=
>     pageblock_nr_pages" loop can pass through 0 and end up trying to access
>     a pageblock before the start of the mem_map[].  (I have not worked out
>     why this never hit me before 4.6-rc2-mm1, it looks much older.)

This is actually my fresh mmotm bug, thanks for catching that!

Fix for:
mm-compaction-wrap-calculating-first-and-last-pfn-of-pageblock.patch

----8<----
