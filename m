Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5269F83200
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 14:17:40 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id h188so14243760wma.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 11:17:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si5555301wru.142.2017.03.08.11.17.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 11:17:39 -0800 (PST)
Subject: Re: [PATCH v3 0/8] try to reduce fragmenting fallbacks
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170308164631.GA12130@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fbc47cf0-2f8f-defc-cd79-50395e9985a7@suse.cz>
Date: Wed, 8 Mar 2017 20:17:39 +0100
MIME-Version: 1.0
In-Reply-To: <20170308164631.GA12130@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com

On 8.3.2017 17:46, Johannes Weiner wrote:
> Is there any other data you would like me to gather?

If you can enable the extfrag tracepoint, it would be nice to have graphs of how
unmovable allocations falling back to movable pageblocks, etc.

Possibly also /proc/pagetypeinfo for numbers of pageblock types.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
