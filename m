Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 41BD66B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 11:46:15 -0500 (EST)
Received: by wmww144 with SMTP id w144so222970270wmw.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 08:46:14 -0800 (PST)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id hh4si5381420wjc.172.2015.12.02.08.46.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 08:46:14 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id AACA098C2C
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 16:46:13 +0000 (UTC)
Date: Wed, 2 Dec 2015 16:46:11 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm/page_alloc.c: use list_{first,last}_entry instead
 of list_entry
Message-ID: <20151202164611.GE2015@techsingularity.net>
References: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 02, 2015 at 11:12:40PM +0800, Geliang Tang wrote:
> To make the intention clearer, use list_{first,last}_entry instead
> of list_entry.
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
