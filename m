Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 692126B0264
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 06:37:21 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so17024620wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 03:37:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lb8si1163246wjc.131.2015.09.22.03.37.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 03:37:20 -0700 (PDT)
Subject: Re: [PATCH v2 3/3] mm, compaction: disginguish contended status in
 tracepoints
References: <1442914365-15949-1-git-send-email-vbabka@suse.cz>
 <1442914365-15949-3-git-send-email-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56012F5F.2050101@suse.cz>
Date: Tue, 22 Sep 2015 12:37:19 +0200
MIME-Version: 1.0
In-Reply-To: <1442914365-15949-3-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

s/disginguish/distinguish/ on the subject, sorry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
