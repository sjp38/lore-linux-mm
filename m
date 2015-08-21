Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id A4BC76B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 04:42:46 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so13513429wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 01:42:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l10si3061750wij.50.2015.08.21.01.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 01:42:44 -0700 (PDT)
Date: Fri, 21 Aug 2015 10:42:38 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, vmscan: unlock page while waiting on writeback
Message-ID: <20150821084237.GA6619@cmpxchg.org>
References: <alpine.LSU.2.11.1508191930390.2073@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1508191930390.2073@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org

On Wed, Aug 19, 2015 at 07:36:31PM -0700, Hugh Dickins wrote:
> This is merely a politeness: I've not found that shrink_page_list() leads
> to deadlock with the page it holds locked across wait_on_page_writeback();
> but nevertheless, why hold others off by keeping the page locked there?
> 
> And while we're at it: remove the mistaken "not " from the commentary
> on this Case 3 (and a distracting blank line from Case 2, if I may).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
