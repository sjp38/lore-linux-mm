Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4DE6B0257
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 11:46:43 -0500 (EST)
Received: by wmec201 with SMTP id c201so262481970wme.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 08:46:42 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id w138si3194046wmw.32.2015.12.02.08.46.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 08:46:42 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id B576698C3B
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 16:46:41 +0000 (UTC)
Date: Wed, 2 Dec 2015 16:46:40 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm/page_alloc.c: use list_for_each_entry in
 mark_free_pages()
Message-ID: <20151202164640.GF2015@techsingularity.net>
References: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
 <7009a8fa2dba33da9bcfe60db4741139c07c8074.1449068845.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <7009a8fa2dba33da9bcfe60db4741139c07c8074.1449068845.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 02, 2015 at 11:12:41PM +0800, Geliang Tang wrote:
> Use list_for_each_entry instead of list_for_each + list_entry to
> simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
