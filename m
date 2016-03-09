Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2765B6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 08:47:32 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so193080534wmp.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 05:47:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x64si10744732wmx.5.2016.03.09.05.47.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 05:47:31 -0800 (PST)
Subject: Re: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with waking
 up kcompactd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <1454938691-2197-5-git-send-email-vbabka@suse.cz>
 <20160302063322.GB32695@js1304-P5Q-DELUXE> <56D6BACB.7060005@suse.cz>
 <CAAmzW4PHAsMvifgV2FpS_FYE78_PzDtADvoBY67usc_9-D4Hjg@mail.gmail.com>
 <56D6F41D.9080107@suse.cz>
 <CAAmzW4PGgYkL9xnCXgSQ=8kW0sJkaYyrxenb_XKHcW1wDGMEyw@mail.gmail.com>
 <56D6FB77.2090801@suse.cz>
 <CAAmzW4METKGH27_tcnBLp1CQU3UK+YmfXJ4MwHuwUfqynAp_eg@mail.gmail.com>
 <56D70543.60806@suse.cz>
 <20160304152507.18b1362f51b0860a1268a977@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E02961.2060403@suse.cz>
Date: Wed, 9 Mar 2016 14:47:13 +0100
MIME-Version: 1.0
In-Reply-To: <20160304152507.18b1362f51b0860a1268a977@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On 03/05/2016 12:25 AM, Andrew Morton wrote:
>> Thanks. Andrew, should I send now patch folding patch 4/5 and 5/5 with 
>> all the accumulated fixlets (including those I sent earlier today) and 
>> combined changelog, or do you want to apply the new fixlets separately 
>> first and let them sit for a week or so? In any case, sorry for the churn.
> 
> Did I get everything?
> 
> http://ozlabs.org/~akpm/mmots/broken-out/mm-kswapd-remove-bogus-check-of-balance_classzone_idx.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-introduce-kcompactd.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-introduce-kcompactd-fix.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-introduce-kcompactd-fix-2.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-introduce-kcompactd-fix-3.patch

Please add the one below here.

> http://ozlabs.org/~akpm/mmots/broken-out/mm-memory-hotplug-small-cleanup-in-online_pages.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-kswapd-replace-kswapd-compaction-with-waking-up-kcompactd.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-kswapd-replace-kswapd-compaction-with-waking-up-kcompactd-fix.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-adapt-isolation_suitable-flushing-to-kcompactd.patch
 
----8<----
