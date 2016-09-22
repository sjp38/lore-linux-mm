Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A98E46B0275
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:18:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b130so74420653wmc.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:18:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n123si2954504wmg.32.2016.09.22.08.18.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 08:18:53 -0700 (PDT)
Subject: Re: [PATCH 0/4] reintroduce compaction feedback for OOM decisions
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160921171830.GH24210@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56f2c2ed-8a58-cf9c-dd00-c0d0e274607a@suse.cz>
Date: Thu, 22 Sep 2016 17:18:48 +0200
MIME-Version: 1.0
In-Reply-To: <20160921171830.GH24210@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>

On 09/21/2016 07:18 PM, Michal Hocko wrote:
> On Tue 06-09-16 15:52:54, Vlastimil Babka wrote:
> 
> We still do not ignore fragindex in the full priority. This part has
> always been quite unclear to me so I cannot really tell whether that
> makes any difference or not but just to be on the safe side I would
> preffer to have _all_ the shortcuts out of the way in the highest
> priority. It is true that this will cause COMPACT_NOT_SUITABLE_ZONE
> so keep retrying but still a complication to understand the workflow.
> 
> What do you think?
 
I was thinking that this shouldn't be a problem on non-costly orders and default
extfrag_threshold. But better be safe. Moreover I think the issue is much more
dangerous for compact_zonelist_suitable() as explained below.

----8<----
