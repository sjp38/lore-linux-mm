Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 745016B0036
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:51:39 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so790270wib.5
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 05:51:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id co16si10984371wjb.120.2014.07.18.05.51.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 05:51:29 -0700 (PDT)
Date: Fri, 18 Jul 2014 13:51:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 2/3] mm: vmscan: remove all_unreclaimable() fix
Message-ID: <20140718125120.GP10819@suse.de>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
 <1405344049-19868-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1405344049-19868-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 14, 2014 at 09:20:48AM -0400, Johannes Weiner wrote:
> As per Mel, use bool for reclaimability throughout and simplify the
> reclaimability tracking in shrink_zones().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
