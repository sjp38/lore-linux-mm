Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 828686B0253
	for <linux-mm@kvack.org>; Sun,  7 Aug 2016 08:32:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so618810419pfg.1
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 05:32:47 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id c69si31289131pfj.224.2016.08.07.05.32.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Aug 2016 05:32:46 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id g202so23260036pfb.1
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 05:32:46 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH 2/2] mm: compaction.c: Add/Modify direct compaction tracepoints
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <7ab4a23a-1311-9579-2d58-263bbcdcd725@suse.cz>
Date: Sun, 7 Aug 2016 18:02:41 +0530
Content-Transfer-Encoding: quoted-printable
Message-Id: <36624B5E-12F3-437D-90B6-E3197D31A0F3@gmail.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com> <7d2c2beef96e76cb01a21eee85ba5611bceb4307.1469629027.git.janani.rvchndrn@gmail.com> <7ab4a23a-1311-9579-2d58-263bbcdcd725@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com, rostedt@goodmis.org


> On Aug 1, 2016, at 6:55 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
>=20
> Yea, this tracepoint has been odd in not printing node/zone in a =
friendly way (it's possible to determine it from zone_start/zone_end =
though, so this is good in general. But instead of printing nid and zid =
like this, it would be nice to unify the output with the other =
tracepoints, e.g.:
>=20
> DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
> [...]
>        TP_printk("node=3D%d zone=3D%-8s order=3D%d ret=3D%s",
>                __entry->nid,
>                __print_symbolic(__entry->idx, ZONE_TYPE),

Sure, I=92ll do that in v2. Thanks!

Also, I guess I should have mentioned that the tracepoint added
at the end of the compaction code wasn=92t just for deriving latency =
information.=20
rc and *contended would give us the result of the compaction attempted,=20=

which I thought would be useful.

I get that begin/end tracepoints aren=92t required here, but how about =
having
trace_mm_compaction_try_to_compact_pages moved to the end to=20
include compaction status?

Janani.
>=20
> Thanks,
> Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
