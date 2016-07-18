Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47F826B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 09:34:25 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id r97so8976224lfi.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 06:34:25 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qw18si1165661wjb.158.2016.07.18.06.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 06:34:23 -0700 (PDT)
Date: Mon, 18 Jul 2016 09:34:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 18/34] mm: rename NR_ANON_PAGES to NR_ANON_MAPPED
Message-ID: <20160718133412.GA14604@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-19-git-send-email-mgorman@techsingularity.net>
 <20160712145801.GJ5881@cmpxchg.org>
 <20160713085516.GI9806@techsingularity.net>
 <20160713130415.GB9905@cmpxchg.org>
 <20160713133701.GK9806@techsingularity.net>
 <20160713141343.244c108e48086055f57b1d79@linux-foundation.org>
 <20160715104605.GO9806@techsingularity.net>
 <20160715153554.f9d12360e31441b720d6a6b1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160715153554.f9d12360e31441b720d6a6b1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 03:35:54PM -0700, Andrew Morton wrote:
> Well I dunno.  We can leave the series as-is for now and we can merge
> the rename-it-back patch sometime during the next -rc cycle if we find
> that people are running around in confusion and tumbling out of high
> windows.

Sounds good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
