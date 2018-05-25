Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 358816B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 16:50:31 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t17-v6so2331579ply.13
        for <linux-mm@kvack.org>; Fri, 25 May 2018 13:50:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bc7-v6si24104820plb.310.2018.05.25.13.50.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 May 2018 13:50:26 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: do not break __GFP_THISNODE by zonelist
 reset
References: <20180525130853.13915-1-vbabka@suse.cz>
 <20180525124300.964a1a15d953e8972625bb0f@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4cd73f77-e6ab-bdd1-69a2-bd0f8413d189@suse.cz>
Date: Fri, 25 May 2018 22:48:16 +0200
MIME-Version: 1.0
In-Reply-To: <20180525124300.964a1a15d953e8972625bb0f@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

On 05/25/2018 09:43 PM, Andrew Morton wrote:
> On Fri, 25 May 2018 15:08:53 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> we might consider this for 4.17 although I don't know if there's anything
>> currently broken. Stable backports should be more important, but will have to
>> be reviewed carefully, as the code went through many changes.
>> BTW I think that also the ac->preferred_zoneref reset is currently useless if
>> we don't also reset ac->nodemask from a mempolicy to NULL first (which we
>> probably should for the OOM victims etc?), but I would leave that for a
>> separate patch.
> 
> Confused.  If nothing is currently broken then why is a backport
> needed?  Presumably because we expect breakage in the future?  Can you
> expand on this?

I mean that SLAB is currently not affected, but in older kernels than
4.7 that don't yet have 511e3a058812 ("mm/slab: make cache_grow() handle
the page allocated on arbitrary node") it is. That's at least 4.4 LTS.
Older ones I'll have to check.
