Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4DB6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 03:22:56 -0500 (EST)
Received: by wmeg8 with SMTP id g8so34795603wme.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:22:56 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id l66si881575wmg.9.2015.11.04.00.22.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 00:22:55 -0800 (PST)
Received: by wmeg8 with SMTP id g8so104114269wme.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:22:55 -0800 (PST)
Date: Wed, 4 Nov 2015 09:22:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/8] mm: lru_deactivate_fn should clear PG_referenced
Message-ID: <20151104082253.GC29607@dhcp22.suse.cz>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-7-git-send-email-minchan@kernel.org>
 <20151030124711.GB23627@dhcp22.suse.cz>
 <20151103011030.GF17906@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151103011030.GF17906@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>

On Tue 03-11-15 10:10:30, Minchan Kim wrote:
> One thing I suspect is GUP with FOLL_TOUCH which calls mark_page_accesssed
> on anonymous page and will mark PG_referenced.

OK, this is what I've missed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
