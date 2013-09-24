Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0FD6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 21:54:40 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so3006896pab.25
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 18:54:40 -0700 (PDT)
Date: Tue, 24 Sep 2013 11:54:20 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v6 0/5] memcg, cgroup: kill css id
Message-Id: <20130924115420.a69505b10763ef89953698a8@canb.auug.org.au>
In-Reply-To: <20130924015211.GD3482@htj.dyndns.org>
References: <524001F8.6070205@huawei.com>
	<20130923130816.GH30946@htj.dyndns.org>
	<20130923131215.GI30946@htj.dyndns.org>
	<5240DD83.1070509@huawei.com>
	<20130923175247.ea5156de.akpm@linux-foundation.org>
	<20130924013058.GB3482@htj.dyndns.org>
	<20130924015211.GD3482@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__24_Sep_2013_11_54_20_+1000_RAsT_ht736N3B=Zx"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--Signature=_Tue__24_Sep_2013_11_54_20_+1000_RAsT_ht736N3B=Zx
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Tejun,

On Mon, 23 Sep 2013 21:52:11 -0400 Tejun Heo <tj@kernel.org> wrote:
>
> (cc'ing Stephen, hi!)

Hi :-)

> On Mon, Sep 23, 2013 at 09:30:58PM -0400, Tejun Heo wrote:
> >=20
> > On Mon, Sep 23, 2013 at 05:52:47PM -0700, Andrew Morton wrote:
> > > > I would love to see this patchset go through cgroup tree. The chang=
es to
> > > > memcg is quite small,
> > >=20
> > > It seems logical to put this in the cgroup tree as that's where most =
of
> > > the impact occurs.
> >=20
> > Cool, applying the changes to cgroup/for-3.13.
>=20
> Stephen, Andrew, cgroup/for-3.13 will cause a minor conflict in
> mm/memcontrol.c with the patch which reverts Michal's reclaim changes.
>=20
>   static void __mem_cgroup_free(struct mem_cgroup *memcg)
>   {
> 	  int node;
> 	  size_t size =3D memcg_size();
>=20
>   <<<<<<< HEAD
>   =3D=3D=3D=3D=3D=3D=3D
> 	  mem_cgroup_remove_from_trees(memcg);
> 	  free_css_id(&mem_cgroup_subsys, &memcg->css);
>=20
>   >>>>>>> 1fa8f71dfa6e28c89afad7ac71dcb19b8c8da8b7
> 	  for_each_node(node)
> 		  free_mem_cgroup_per_zone_info(memcg, node);
>=20
> It's a context conflict and just removing free_css_id() call resolves
> it.
>=20
>   static void __mem_cgroup_free(struct mem_cgroup *memcg)
>   {
> 	  int node;
> 	  size_t size =3D memcg_size();
>=20
> 	  mem_cgroup_remove_from_trees(memcg);
>=20
> 	  for_each_node(node)
> 		  free_mem_cgroup_per_zone_info(memcg, node);

Thanks for the heads up, I guess I'll see that tomorrow.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__24_Sep_2013_11_54_20_+1000_RAsT_ht736N3B=Zx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBCAAGBQJSQPDRAAoJEECxmPOUX5FE55AP/13eg9hHuo1OMUOknTklxTW5
Lu2i8Ic+9Ku5DTkEKN4Q/CLgvL4chcJXB9xFG5V/OWjE6Rn+DdhAMGQqiRBKdb85
tPJS98hTFQiVR4yJOg24N4ZiZYNP1fZKBRJR76ZfHcKY5ai6v7cqiJt2o0dFhh5G
cOUzrRq9quSjX+VDTfXj0Uw4tUMTFXdV4ar8y8XrjgczQ5NmzA568xwkqvSkvs+Z
qXUb3I0Y+e3EZ3MrqWu3YLW7z8dmPae+xprMa3y1Renhyl0w5sQcTqU0VULpe0mj
1R53fi8fu0rCAZGfT4eUQ7zb4eteggPnBHe8O5XZvouLqHMVUpsLITuj6DoIarQm
L1NMlnnPLYpCWGUF38zrvnwZ/zufQXnIr+RGptM889qSP0YmrUIUqoLQIYNC2tNF
GPFYKdVftsPfU8v/ITl+yXzrKDnc3Nz4pb/dW6XJPiQ+NumHWZX10MahjSMjBVsl
HovFxNqp81NKrjTwgSEWhqWnlQTrp4tmt+PmB+YPJcr+viRlCy8CqAlagwLzpmie
wmKVqLzeHzMlJQHwUxFKffMFYE1N3IkSnCop2RGbFDlyglKigd1iGk9Psekw60no
jelE3X4eh5UoBmgNxBgInHfUub1kEbb9gItRZ4RpNYNPYCGrq2lctCrekyt3OujD
XmHkD7nK9jFcz7oVjdD8
=Ni4y
-----END PGP SIGNATURE-----

--Signature=_Tue__24_Sep_2013_11_54_20_+1000_RAsT_ht736N3B=Zx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
