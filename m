Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 411FA6B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 03:53:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n4-v6so614963edr.5
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 00:53:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a44-v6si1738250edc.461.2018.08.08.00.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 00:53:35 -0700 (PDT)
Subject: Re: [PATCH v2] proc: add percpu populated pages count to meminfo
References: <20180807184723.74919-1-dennisszhou@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4eb4a0cc-2304-b6e2-06dd-ce0ade5d537e@suse.cz>
Date: Wed, 8 Aug 2018 09:53:32 +0200
MIME-Version: 1.0
In-Reply-To: <20180807184723.74919-1-dennisszhou@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>
Cc: kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On 08/07/2018 08:47 PM, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> Currently, percpu memory only exposes allocation and utilization
> information via debugfs. This more or less is only really useful for
> understanding the fragmentation and allocation information at a
> per-chunk level with a few global counters. This is also gated behind a
> config. BPF and cgroup, for example, have seen an increase use causing
> increased use of percpu memory. Let's make it easier for someone to
> identify how much memory is being used.
> 
> This patch adds the "Percpu" stat to meminfo to more easily look up how
> much percpu memory is in use. This number includes the cost for all
> allocated backing pages and not just isnight at the a unit, per chunk
> level. Metadata is excluded. I think excluding metadata is fair because
> the backing memory scales with the numbere of cpus and can quickly
> outweigh the metadata. It also makes this calculation light.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.
