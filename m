Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 907626B0411
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:00:56 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id ez4so67140071wjd.2
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 14:00:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u18si3704191wrd.248.2017.02.15.14.00.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Feb 2017 14:00:55 -0800 (PST)
Subject: Re: [PATCH 0/3] Reduce amount of time kswapd sleeps prematurely
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215123055.b8041d7b6bdbcca9c5fd8dd9@linux-foundation.org>
 <20170215212906.3myab4545wa2f3yc@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <06a52328-504a-deb3-d211-5ddd2ba1cc71@suse.cz>
Date: Wed, 15 Feb 2017 23:00:54 +0100
MIME-Version: 1.0
In-Reply-To: <20170215212906.3myab4545wa2f3yc@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 15.2.2017 22:29, Mel Gorman wrote:
> On Wed, Feb 15, 2017 at 12:30:55PM -0800, Andrew Morton wrote:
>> On Wed, 15 Feb 2017 09:22:44 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
>>
>>> This patchset is based on mmots as of Feb 9th, 2016. The baseline is
>>> important as there are a number of kswapd-related fixes in that tree and
>>> a comparison against v4.10-rc7 would be almost meaningless as a result.
>>
>> It's very late to squeeze this into 4.10.  We can make it 4.11 material
>> and perhaps tag it for backporting into 4.10.1?
> 
> It would be important that Johannes's patches go along with then because
> I'm relied on Johannes' fixes to deal with pages being inappropriately
> written back from reclaim context when I was analysing the workload.
> I'm thinking specifically about these patches
> 
> mm-vmscan-scan-dirty-pages-even-in-laptop-mode.patch
> mm-vmscan-kick-flushers-when-we-encounter-dirty-pages-on-the-lru.patch
> mm-vmscan-kick-flushers-when-we-encounter-dirty-pages-on-the-lru-fix.patch
> mm-vmscan-remove-old-flusher-wakeup-from-direct-reclaim-path.patch
> mm-vmscan-only-write-dirty-pages-that-the-scanner-has-seen-twice.patch
> mm-vmscan-move-dirty-pages-out-of-the-way-until-theyre-flushed.patch
> mm-vmscan-move-dirty-pages-out-of-the-way-until-theyre-flushed-fix.patch
> 
> This is 4.11 material for sure but I would not automatically try merging
> them to 4.10 unless those patches were also included, ideally with a rerun
> of just those patches against 4.10 to make sure there are no surprises
> lurking in there.

I wonder if we should also care about 4.9 which will be LTS, if we decide to
look at stable at all. IIUC at least the problem that patch 1/3 fixes (wrt
kcompactd not being woken up) is there since 4.8?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
