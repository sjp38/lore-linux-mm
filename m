Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 189E16B0253
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 12:14:23 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o3so12797540wjo.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 09:14:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 199si8165546wmm.166.2016.12.14.09.14.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 09:14:21 -0800 (PST)
Subject: Re: [PATCH 1/3] mm, trace: extract COMPACTION_STATUS and ZONE_TYPE to
 a common header
References: <20161214145324.26261-1-mhocko@kernel.org>
 <20161214145324.26261-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1a4894b1-4caf-97c5-9e75-018b89307103@suse.cz>
Date: Wed, 14 Dec 2016 18:14:20 +0100
MIME-Version: 1.0
In-Reply-To: <20161214145324.26261-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/14/2016 03:53 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> COMPACTION_STATUS resp. ZONE_TYPE are currently used to translate enum
> compact_result resp. struct zone index into their symbolic names for
> an easier post processing. The follow up patch would like to reuse
> this as well. The code involves some preprocessor black magic which is
> better not duplicated elsewhere so move it to a common mm tracing relate
> header.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
