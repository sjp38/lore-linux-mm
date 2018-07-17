Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0278F6B026A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 15:13:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b25-v6so940135eds.17
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:13:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j19-v6si327889eds.376.2018.07.17.12.13.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 12:13:42 -0700 (PDT)
Subject: Re: [PATCH v2 5/7] mm: rename and change semantics of
 nr_indirectly_reclaimable_bytes
References: <20180618091808.4419-6-vbabka@suse.cz>
 <201806201923.mC5ZpigB%fengguang.wu@intel.com>
 <38c6a6e1-c5e0-fd7d-4baf-1f0f09be5094@suse.cz>
 <20180629211201.GA14897@castle.DHCP.thefacebook.com>
 <ef2dea13-0102-c4bc-a28f-c1b2408f0753@suse.cz>
 <20180702165223.GA17295@castle.DHCP.thefacebook.com>
 <bfdb3fb1-5d81-e17c-e456-083cca04e2cc@suse.cz>
 <20180717185451.GA18762@castle.DHCP.thefacebook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0e1e8870-9c98-2330-e978-f927c33eec49@suse.cz>
Date: Tue, 17 Jul 2018 21:11:22 +0200
MIME-Version: 1.0
In-Reply-To: <20180717185451.GA18762@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vijayanand Jitta <vjitta@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>

On 07/17/2018 08:54 PM, Roman Gushchin wrote:
> On Tue, Jul 17, 2018 at 10:44:07AM +0200, Vlastimil Babka wrote:
>> On 07/02/2018 06:52 PM, Roman Gushchin wrote:
>>> On Sat, Jun 30, 2018 at 12:09:27PM +0200, Vlastimil Babka wrote:
>>>
>>> If these per-cpu data is something like per-cpu refcounters,
>>> which are using to manage reclaimable objects (e.g. cgroup css objects).
>>> Of course, they are not always reclaimable, but in certain states.
>>
>> BTW, seems you seem interested, could you provide some more formal
>> review as well? Others too. We don't need to cover all use cases
>> immediately, when the patchset is apparently stalled due to lack of
>> review. Thanks!
> 
> Sure!

Thanks!

> The patchset looks sane at a first glance, but I need some time
> to dig deeper. Is v2 the final version?

There was a fixlet on top and some added changelog text, so I'll do a v3
tomorrow incorporating that to make things easier for everyone.

> Thanks!
> 
