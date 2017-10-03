Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2655C6B0033
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 15:22:36 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k10so9851030wrk.4
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 12:22:36 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id c18si6495178edc.309.2017.10.03.12.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 12:22:35 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 8F33E1C3118
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 20:22:34 +0100 (IST)
Date: Tue, 3 Oct 2017 20:22:33 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm/mempolicy: fix NUMA_INTERLEAVE_HIT counter
Message-ID: <20171003192233.6drmrp5huoxpctah@techsingularity.net>
References: <20171003164720.22130-1-aryabinin@virtuozzo.com>
 <20171003191003.8573-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171003191003.8573-1-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kemi Wang <kemi.wang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 03, 2017 at 10:10:03PM +0300, Andrey Ryabinin wrote:
> Commit 3a321d2a3dde separated NUMA counters from zone counters, but
> the NUMA_INTERLEAVE_HIT call site wasn't updated to use the new interface.
> So alloc_page_interleave() actually increments NR_ZONE_INACTIVE_FILE
> instead of NUMA_INTERLEAVE_HIT.
> 
> Fix this by using __inc_numa_state() interface to increment
> NUMA_INTERLEAVE_HIT.
> 
> Fixes: 3a321d2a3dde ("mm: change the call sites of numa statistics items")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
