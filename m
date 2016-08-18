Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F82E6B026A
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 08:13:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so14728338wmu.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:13:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fq8si1600279wjc.159.2016.08.18.05.13.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 05:13:51 -0700 (PDT)
Subject: Re: [PATCH v6 08/11] mm, compaction: create compact_gap wrapper
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-9-vbabka@suse.cz>
 <20160816061518.GE17448@js1304-P5Q-DELUXE>
 <656fea7f-753d-df56-744a-50b90f9a3842@suse.cz>
 <20160816064104.GG17448@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7b6aed1f-fdf8-2063-9ff4-bbe4de712d37@suse.cz>
Date: Thu, 18 Aug 2016 14:13:49 +0200
MIME-Version: 1.0
In-Reply-To: <20160816064104.GG17448@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/16/2016 08:41 AM, Joonsoo Kim wrote:
>> free pages for probability of compaction success, so I don't think
>> it's worth complicating the compact_gap() formula.
> 
> I agree that it's not worth complicating the compact_gap() formula but
> it would be better to fix the comment?

OK, Andrew can you add this -fix?
Thanks.

----8<----
