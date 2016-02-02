Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5FA6B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 03:41:48 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p63so11277972wmp.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 00:41:48 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id h6si530377wjw.25.2016.02.02.00.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 00:41:47 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 218771C23C0
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 08:41:47 +0000 (GMT)
Date: Tue, 2 Feb 2016 08:41:45 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/Kconfig: correct description of
 DEFERRED_STRUCT_PAGE_INIT
Message-ID: <20160202084145.GC8337@techsingularity.net>
References: <1453995448-27582-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1453995448-27582-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 28, 2016 at 04:37:28PM +0100, Vlastimil Babka wrote:
> The description mentions kswapd threads, while the deferred struct page
> initialization is actually done by one-off "pgdatinitX" threads. Fix the
> description so that potentially users are not confused about pgdatinit threads
> using CPU after boot instead of kswapd.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

This was an oversight when I moved to using kernel threads to do the
initialisation instead. Thanks for catching it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
