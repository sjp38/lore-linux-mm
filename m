Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 848406B000A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 04:55:44 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 2-v6so1872554plc.11
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 01:55:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v34-v6si12569366plg.491.2018.07.31.01.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 01:55:43 -0700 (PDT)
Subject: Re: [PATCH v3 7/7] mm, slab: shorten kmalloc cache names for large
 sizes
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180718133620.6205-8-vbabka@suse.cz>
 <01000164ebe0d06f-8f639717-8d32-4eb9-9cc1-708332b12ca6-000000@email.amazonses.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9e019ae9-b6a8-c824-8913-dd02a8e6e6ce@suse.cz>
Date: Tue, 31 Jul 2018 10:55:39 +0200
MIME-Version: 1.0
In-Reply-To: <01000164ebe0d06f-8f639717-8d32-4eb9-9cc1-708332b12ca6-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On 07/30/2018 05:48 PM, Christopher Lameter wrote:
> On Wed, 18 Jul 2018, Vlastimil Babka wrote:
> 
>> +static const char *
>> +kmalloc_cache_name(const char *prefix, unsigned int size)
>> +{
>> +
>> +	static const char units[3] = "\0kM";
>> +	int idx = 0;
>> +
>> +	while (size >= 1024 && (size % 1024 == 0)) {
>> +		size /= 1024;
>> +		idx++;
>> +	}
>> +
>> +	return kasprintf(GFP_NOWAIT, "%s-%u%c", prefix, size, units[idx]);
>> +}
> 
> This is likely to occur elsewhere in the kernel. Maybe generalize it a
> bit?

I'll try later on top, as that's generic printf code then.

> Acked-by: Christoph Lameter <cl@linux.com>

Thanks for all acks.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
