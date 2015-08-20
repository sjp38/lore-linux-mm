Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 21BDB6B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 10:46:00 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so147612048wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 07:45:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj5si8809401wjb.214.2015.08.20.07.45.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 07:45:58 -0700 (PDT)
Subject: Re: [PATCH 01/10] mm, page_alloc: Delete the zonelist_cache
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-2-git-send-email-mgorman@techsingularity.net>
 <55D5D68E.6040206@suse.cz> <20150820141720.GE12432@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D5E825.9000207@suse.cz>
Date: Thu, 20 Aug 2015 16:45:57 +0200
MIME-Version: 1.0
In-Reply-To: <20150820141720.GE12432@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 08/20/2015 04:17 PM, Mel Gorman wrote:
> On Thu, Aug 20, 2015 at 03:30:54PM +0200, Vlastimil Babka wrote:
>> These hunks appear unrelated to zonelist cache? Also they move the
>> evaluation of cpuset_current_mems_allowed

Ah forgot to delete the "Also" part. I wanted to write that it moves the 
evaluation away from inside the read_mems_allowed_begin() - 
read_mems_allowed_retry() pair. But then I realized it's just taking a 
*reference* and not going through cpuset_current_mems_allowed yet, so 
it's probably OK. Just out of place in this patch.

> They are rebase-related brain damage :(. I'll fix it and retest.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
