Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 79C826B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 07:53:26 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id t92so1939940wrc.13
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 04:53:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x56si1534345edm.293.2017.11.29.04.53.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 04:53:25 -0800 (PST)
Subject: Re: [PATCH] mm, compaction: direct freepage allocation for async
 direct compaction
References: <20171122143321.29501-1-hannes@cmpxchg.org>
 <32b5f1b6-e3aa-4f15-4ec6-5cbb5fe158d0@suse.cz>
 <20171128153416.f7062caba47d86eb4eb15b8b@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <62741f32-a56a-8113-073e-322300545f5f@suse.cz>
Date: Wed, 29 Nov 2017 13:51:55 +0100
MIME-Version: 1.0
In-Reply-To: <20171128153416.f7062caba47d86eb4eb15b8b@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 11/29/2017 12:34 AM, Andrew Morton wrote:
> On Wed, 22 Nov 2017 15:52:55 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>>
>> Thanks a lot, that's very encouraging!
> 
> Yup.
> 
> Should we proceed with this patch for now, or wait for something better
> to come along?

I'm working on the refined version, so we don't need to take the old one
now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
