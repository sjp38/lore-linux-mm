Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24CBA8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:00:21 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id v187so5673040ywv.15
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:00:21 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m7si43766048ywe.146.2019.01.10.04.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 04:00:20 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [v3 PATCH 5/5] doc: memcontrol: add description for
 wipe_on_offline
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <1547061285-100329-6-git-send-email-yang.shi@linux.alibaba.com>
Date: Thu, 10 Jan 2019 05:00:13 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <0746F690-2C0C-4041-842A-19CEB28A5E45@oracle.com>
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
 <1547061285-100329-6-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, hannes@cmpxchg.org, shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Just a few grammar corrections since this is going into Documentation:


> On Jan 9, 2019, at 12:14 PM, Yang Shi <yang.shi@linux.alibaba.com> =
wrote:
>=20
> Add desprition of wipe_on_offline interface in cgroup documents.
Add a description of the wipe_on_offline interface to the cgroup =
documents.

> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> Documentation/admin-guide/cgroup-v2.rst |  9 +++++++++
> Documentation/cgroup-v1/memory.txt      | 10 ++++++++++
> 2 files changed, 19 insertions(+)
>=20
> diff --git a/Documentation/admin-guide/cgroup-v2.rst =
b/Documentation/admin-guide/cgroup-v2.rst
> index 0290c65..e4ef08c 100644
> --- a/Documentation/admin-guide/cgroup-v2.rst
> +++ b/Documentation/admin-guide/cgroup-v2.rst
> @@ -1303,6 +1303,15 @@ PAGE_SIZE multiple when read back.
>         memory pressure happens. If you want to avoid that, =
force_empty will be
>         useful.
>=20
> +  memory.wipe_on_offline
> +
> +        This is similar to force_empty, but it just does memory =
reclaim
> +        asynchronously in css offline kworker.
> +
> +        Writing into 1 will enable it, disable it by writing into 0.
Writing a 1 will enable it; writing a 0 will disable it.

> +
> +        It would reclaim as much as possible memory just as what =
force_empty does.
It will reclaim as much memory as possible, just as force_empty does.

> +
>=20
> Usage Guidelines
> ~~~~~~~~~~~~~~~~
> diff --git a/Documentation/cgroup-v1/memory.txt =
b/Documentation/cgroup-v1/memory.txt
> index 8e2cb1d..1c6e1ca 100644
> --- a/Documentation/cgroup-v1/memory.txt
> +++ b/Documentation/cgroup-v1/memory.txt
> @@ -71,6 +71,7 @@ Brief summary of control files.
>  memory.stat			 # show various statistics
>  memory.use_hierarchy		 # set/show hierarchical account enabled
>  memory.force_empty		 # trigger forced page reclaim
> + memory.wipe_on_offline		 # trigger forced page reclaim =
when offlining
>  memory.pressure_level		 # set memory pressure =
notifications
>  memory.swappiness		 # set/show swappiness parameter of =
vmscan
> 				 (See sysctl's vm.swappiness)
> @@ -581,6 +582,15 @@ hierarchical_<counter>=3D<counter pages> N0=3D<node=
 0 pages> N1=3D<node 1 pages> ...
>=20
> The "total" count is sum of file + anon + unevictable.
>=20
> +5.7 wipe_on_offline
> +
> +This is similar to force_empty, but it just does memory reclaim =
asynchronously
> +in css offline kworker.
> +
> +Writing into 1 will enable it, disable it by writing into 0.
Writing a 1 will enable it; writing a 0 will disable it.

> +
> +It would reclaim as much as possible memory just as what force_empty =
does.
It will reclaim as much memory as possible, just as force_empty does.

> +
> 6. Hierarchy support
>=20
> The memory controller supports a deep hierarchy and hierarchical =
accounting.
> --=20
> 1.8.3.1
>=20
