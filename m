Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5585D6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:31:12 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id v188so119077384wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 02:31:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ld8si33346619wjc.77.2016.04.12.02.31.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 02:31:11 -0700 (PDT)
Subject: Re: mmotm woes, mainly compaction
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570CC05C.6070308@suse.cz>
Date: Tue, 12 Apr 2016 11:31:08 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 04/12/2016 09:18 AM, Hugh Dickins wrote:
> 3. /proc/sys/vm/stat_refresh warns nr_isolated_anon and nr_isolated_file
>     go increasingly negative under compaction: which would add delay when
>     should be none, or no delay when should delay.  putback_movable_pages()
>     decrements the NR_ISOLATED counts which acct_isolated() increments,
>     so isolate_migratepages_block() needs to acct before putback in that
>     special case, and isolate_migratepages_range() can always do the acct
>     itself, leaving migratepages putback to caller like most other places.

Sigh, looks like I notoriously suck at the nr_isolated_* accounting. The
isolate_migratepages_range() is also due to my 3.18 commit. Back then,
Joonsoo caught the problem for compaction side, but CMA issue remains.
Sorry and thanks.

----8<----
