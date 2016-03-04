Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9D93B6B0253
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 18:25:10 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p65so38970255wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 15:25:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b2si6243249wjy.233.2016.03.04.15.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 15:25:09 -0800 (PST)
Date: Fri, 4 Mar 2016 15:25:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with
 waking up kcompactd
Message-Id: <20160304152507.18b1362f51b0860a1268a977@linux-foundation.org>
In-Reply-To: <56D70543.60806@suse.cz>
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
	<1454938691-2197-5-git-send-email-vbabka@suse.cz>
	<20160302063322.GB32695@js1304-P5Q-DELUXE>
	<56D6BACB.7060005@suse.cz>
	<CAAmzW4PHAsMvifgV2FpS_FYE78_PzDtADvoBY67usc_9-D4Hjg@mail.gmail.com>
	<56D6F41D.9080107@suse.cz>
	<CAAmzW4PGgYkL9xnCXgSQ=8kW0sJkaYyrxenb_XKHcW1wDGMEyw@mail.gmail.com>
	<56D6FB77.2090801@suse.cz>
	<CAAmzW4METKGH27_tcnBLp1CQU3UK+YmfXJ4MwHuwUfqynAp_eg@mail.gmail.com>
	<56D70543.60806@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, 2 Mar 2016 16:22:43 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 03/02/2016 03:59 PM, Joonsoo Kim wrote:
> > 2016-03-02 23:40 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> >> On 03/02/2016 03:22 PM, Joonsoo Kim wrote:
> >>
> >> So I understand that patch 5 would be just about this?
> >>
> >> -       if (compaction_restarting(zone, cc->order) && !current_is_kcompactd())
> >> +       if (compaction_restarting(zone, cc->order))
> >>                  __reset_isolation_suitable(zone);
> >
> > Yeah, you understand correctly. :)
> >
> >> I'm more inclined to fold it in that case.
> >
> > Patch would be just simple, but, I guess it would cause some difference
> > in test result. But, I'm okay for folding.
> 
> Thanks. Andrew, should I send now patch folding patch 4/5 and 5/5 with 
> all the accumulated fixlets (including those I sent earlier today) and 
> combined changelog, or do you want to apply the new fixlets separately 
> first and let them sit for a week or so? In any case, sorry for the churn.

Did I get everything?

http://ozlabs.org/~akpm/mmots/broken-out/mm-kswapd-remove-bogus-check-of-balance_classzone_idx.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-introduce-kcompactd.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-introduce-kcompactd-fix.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-introduce-kcompactd-fix-2.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-introduce-kcompactd-fix-3.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-memory-hotplug-small-cleanup-in-online_pages.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-kswapd-replace-kswapd-compaction-with-waking-up-kcompactd.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-kswapd-replace-kswapd-compaction-with-waking-up-kcompactd-fix.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-adapt-isolation_suitable-flushing-to-kcompactd.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
