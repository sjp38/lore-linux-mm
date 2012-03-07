Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 8007D6B00E7
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 17:22:01 -0500 (EST)
Date: Thu, 8 Mar 2012 01:13:59 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] memcg: revise the position of threshold index while
 unregistering event
Message-ID: <20120307231359.GB10238@shutemov.name>
References: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Sha Zhengju <handai.szj@taobao.com>

On Tue, Mar 06, 2012 at 08:12:23PM +0800, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
>=20
> Index current_threshold should point to threshold just below or equal to =
usage.
> See below:
> http://www.spinics.net/lists/cgroups/msg00844.html
>=20
>=20
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Reviewved-by: Kirill A. Shutemov <kirill@shutemov.name>

>=20
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 22d94f5..cd40d67 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4398,7 +4398,7 @@ static void mem_cgroup_usage_unregister_event(struc=
t cgroup *cgrp,
>  			continue;
> =20
>  		new->entries[j] =3D thresholds->primary->entries[i];
> -		if (new->entries[j].threshold < usage) {
> +		if (new->entries[j].threshold <=3D usage) {
>  			/*
>  			 * new->current_threshold will not be used
>  			 * until rcu_assign_pointer(), so it's safe to increment
> --=20
> 1.7.4.1
>=20

--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
