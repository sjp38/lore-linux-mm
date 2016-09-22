Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 095F76B026F
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:59:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so73422281wmg.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 07:59:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x188si2870857wmx.16.2016.09.22.07.59.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 07:59:55 -0700 (PDT)
Subject: Re: [PATCH 2/4] mm, compaction: more reliably increase direct
 compaction priority
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160906135258.18335-3-vbabka@suse.cz>
 <20160921171348.GF24210@dhcp22.suse.cz>
 <f1670976-b4da-5d2c-0a85-37f9a87d6868@suse.cz>
 <20160922140821.GG11875@dhcp22.suse.cz>
 <20160922145237.GH11875@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <deec7319-2976-6d34-ab7b-afbb3f6c32f8@suse.cz>
Date: Thu, 22 Sep 2016 16:59:51 +0200
MIME-Version: 1.0
In-Reply-To: <20160922145237.GH11875@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 09/22/2016 04:52 PM, Michal Hocko wrote:
> On Thu 22-09-16 16:08:21, Michal Hocko wrote:
>> On Thu 22-09-16 14:51:48, Vlastimil Babka wrote:
>> > >From 465e1bd61b7a6d6901a44f09b1a76514dbc220fa Mon Sep 17 00:00:00 2001
>> > From: Vlastimil Babka <vbabka@suse.cz>
>> > Date: Thu, 22 Sep 2016 13:54:32 +0200
>> > Subject: [PATCH] mm, compaction: more reliably increase direct compaction
>> >  priority-fix
>> > 
>> > When increasing the compaction priority, also reset retries. Otherwise we can
>> > consume all retries on the lower priorities.
>> 
>> OK, this is an improvement. I am just thinking that we might want to
>> pull
>> 	if (order && compaction_made_progress(compact_result))
>> 		compaction_retries++;
>> 
>> into should_compact_retry as well. I've had it there originally because
>> it was in line with no_progress_loops but now that we have compaction
>> priorities it would fit into retry logic better. As a plus it would
>> count only those compaction rounds where we we didn't have to rely on
>                                                  did that should be
> 
>> the compaction retry logic. What do you think?

Makes sense.

-----8<-----
