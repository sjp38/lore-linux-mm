Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7296B0389
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:53:43 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o16so35669967wra.2
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:53:43 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id h28si5041505wmi.75.2017.02.13.02.53.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 02:53:42 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 362839886A
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:53:42 +0000 (UTC)
Date: Mon, 13 Feb 2017 10:53:41 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 05/10] mm, compaction: change migrate_async_suitable()
 to suitable_migration_source()
Message-ID: <20170213105341.dw2bupkuni3532rz@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-6-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-6-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:38PM +0100, Vlastimil Babka wrote:
> Preparation for making the decisions more complex and depending on
> compact_control flags. No functional change.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
