Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 477256B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 03:15:16 -0500 (EST)
Received: by wmll128 with SMTP id l128so107214118wml.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:15:15 -0800 (PST)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id j11si278466wjq.53.2015.11.04.00.15.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 00:15:14 -0800 (PST)
Received: by wicll6 with SMTP id ll6so26779034wic.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:15:14 -0800 (PST)
Date: Wed, 4 Nov 2015 09:15:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: move lazily freed pages to inactive list
Message-ID: <20151104081512.GB29607@dhcp22.suse.cz>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-6-git-send-email-minchan@kernel.org>
 <20151030172212.GB44946@kernel.org>
 <20151103005223.GD17906@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151103005223.GD17906@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, yalin.wang2010@gmail.com, "Wang, Yalin" <Yalin.Wang@sonymobile.com>

On Tue 03-11-15 09:52:23, Minchan Kim wrote:
[...]
> I believe adding new LRU list would be controversial(ie, not trivial)
> for maintainer POV even though code wouldn't be complicated.
> So, I want to see problems in *real practice*, not any theoritical
> test program before diving into that.
> To see such voice of request, we should release the syscall.
> So, I want to push this first.

Completely agreed. The functionality is useful already and a new LRU
list is not justified yet.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
