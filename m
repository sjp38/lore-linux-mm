Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67BFE8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 19:00:19 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id t143so1094780itc.9
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 16:00:19 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g4si13086797jae.39.2019.01.23.16.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 16:00:18 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/2] mm: Rename ambiguously named memory.stat counters and
 functions
Date: Wed, 23 Jan 2019 23:59:47 +0000
Message-ID: <20190123235940.GA21563@castle.DHCP.thefacebook.com>
References: <20190123223049.GA9149@chrisdown.name>
In-Reply-To: <20190123223049.GA9149@chrisdown.name>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A2982AC1C3D33348A4FC8F9CC8E0A110@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Dennis Zhou <dennis@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kernel Team <Kernel-team@fb.com>

On Wed, Jan 23, 2019 at 05:30:49PM -0500, Chris Down wrote:
> I spent literally an hour trying to work out why an earlier version of
> my memory.events aggregation code doesn't work properly, only to find
> out I was calling memcg->events instead of memcg->memory_events, which
> is fairly confusing.
>=20
> This naming seems in need of reworking, so make it harder to do the
> wrong thing by using vmevents instead of events, which makes it more
> clear that these are vm counters rather than memcg-specific counters.
>=20
> There are also a few other inconsistent names in both the percpu and
> aggregated structs, so these are all cleaned up to be more coherent and
> easy to understand.
>=20
> This commit contains code cleanup only: there are no logic changes.
>=20
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> To: Andrew Morton <akpm@linux-foundation.org>

s/To/Cc

> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Dennis Zhou <dennis@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com
> ---
> include/linux/memcontrol.h |  24 +++----
> mm/memcontrol.c            | 137 +++++++++++++++++++------------------
> 2 files changed, 82 insertions(+), 79 deletions(-)
>=20
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index b0eb29ea0d9c..380a212a8c52 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -94,8 +94,8 @@ enum mem_cgroup_events_target {
> 	MEM_CGROUP_NTARGETS,
> };
>=20
> -struct mem_cgroup_stat_cpu {
> -	long count[MEMCG_NR_STAT];
> +struct memcg_vmstats_percpu {
> +	long stat[MEMCG_NR_STAT];

I'd personally go with memcg_vmstat_percpu. Not insisting,
but you end up using both vmstat and vmstats, which isn't very
consistent.

Other than that looks good to me. Please, feel free to add
Acked-by: Roman Gushchin <guro@fb.com>

Thanks!
