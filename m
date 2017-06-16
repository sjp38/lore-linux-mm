Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 136F86B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:44:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y19so7139605wrc.8
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 04:44:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c30si1991719wrb.192.2017.06.16.04.44.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 04:44:02 -0700 (PDT)
Date: Fri, 16 Jun 2017 13:44:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/4] mm, hugetlb: allow proper node fallback dequeue
Message-ID: <20170616114359.GJ30580@dhcp22.suse.cz>
References: <20170613090039.14393-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170613090039.14393-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

JFYI I will repost sometimes next week unless there is another feedback
by then.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
