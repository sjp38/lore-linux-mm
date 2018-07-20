Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B88A6B0010
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:47:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b9-v6so4278995edn.18
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 02:47:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t27-v6si626065edd.157.2018.07.20.02.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 02:47:23 -0700 (PDT)
Subject: Re: [PATCH v3 0/7] kmalloc-reclaimable caches
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180719195332.GB26595@castle.DHCP.thefacebook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8ed44a53-fa20-a7ff-c662-72de9a9fd9e4@suse.cz>
Date: Fri, 20 Jul 2018 11:45:02 +0200
MIME-Version: 1.0
In-Reply-To: <20180719195332.GB26595@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>, Vijayanand Jitta <vjitta@codeaurora.org>

On 07/19/2018 09:53 PM, Roman Gushchin wrote:
>> Vlastimil
> Overall the patchset looks solid to me.
> Please, feel free to add
> Acked-by: Roman Gushchin <guro@fb.com>

Thanks!

> Two small nits:
> 1) The last patch is unrelated to the main idea,
> and can potentially cause ABI breakage.

Yes, that's why it's last.

> I'd separate it from the rest of the patchset.

It's not independent though because there would be conflicts. It has to
be decided if it goes before of after the rest. Putting it last in the
series makes the order clear and makes it possible to revert it in case
it does break any users, without disrupting the rest of the series.

> 2) It's actually re-opening the security issue for SLOB
> users. Is the memory overhead really big enough to
> justify that?

I assume that anyone choosing SLOB has a tiny embedded device which runs
only pre-flashed code, so that's less of an issue. If somebody can
trigger the issue remotely, there are likely also other ways to exhaust
the limited memory there?

> Thanks!
