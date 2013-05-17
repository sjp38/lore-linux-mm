Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 7D55E6B0032
	for <linux-mm@kvack.org>; Sat, 18 May 2013 00:21:42 -0400 (EDT)
Received: by mail-ia0-f174.google.com with SMTP id r13so3776865iar.19
        for <linux-mm@kvack.org>; Fri, 17 May 2013 21:21:41 -0700 (PDT)
Date: Fri, 17 May 2013 00:46:13 -0500
From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH] memcg: update TODO list in Documentation
References: <5195A41D.7050507@huawei.com>
In-Reply-To: <5195A41D.7050507@huawei.com> (from lizefan@huawei.com on Thu
	May 16 22:29:33 2013)
Message-Id: <1368769573.18069.254@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On 05/16/2013 10:29:33 PM, Li Zefan wrote:
> hugetlb cgroup has already been implemented.
>=20
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>  Documentation/cgroups/memory.txt | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>=20
> diff --git a/Documentation/cgroups/memory.txt =20
> b/Documentation/cgroups/memory.txt
> index ddf4f93..327acec 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -834,10 +834,9 @@ Test:
>=20
>  12. TODO
>=20
> -1. Add support for accounting huge pages (as a separate controller)
> -2. Make per-cgroup scanner reclaim not-shared pages first
> -3. Teach controller to account for shared-pages
> -4. Start reclamation in the background when the limit is
> +1. Make per-cgroup scanner reclaim not-shared pages first
> +2. Teach controller to account for shared-pages
> +3. Start reclamation in the background when the limit is
>     not yet hit but the usage is getting closer
>=20
>  Summary

Acked-by: Rob Landley <rob@landley.net>

If the memcg guys don't grab this, please send to trivial@kernel.org.

Rob=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
