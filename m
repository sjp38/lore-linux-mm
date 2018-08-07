Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4406B6B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 16:11:16 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l13-v6so14298670qth.8
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 13:11:16 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id b190-v6si2251572qke.317.2018.08.07.13.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 13:11:15 -0700 (PDT)
Date: Tue, 7 Aug 2018 13:10:32 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] proc: add percpu populated pages count to meminfo
Message-ID: <20180807201028.GA12087@castle.DHCP.thefacebook.com>
References: <20180807184723.74919-1-dennisszhou@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180807184723.74919-1-dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Tue, Aug 07, 2018 at 11:47:23AM -0700, Dennis Zhou wrote:
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

Acked-by: Roman Gushchin <guro@fb.com>

It's super useful! I've seen hosts in production which have
tens and hundreds on megabytes in per-cpu memory, and with
vmalloc counters being defined to 0, it's really hard
to notice and track down.

Thanks, Dennis!
