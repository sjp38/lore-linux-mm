Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id ADF416B0387
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 02:00:11 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f21so6098574pgi.4
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 23:00:11 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id j29si942426pgn.197.2017.02.27.23.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 23:00:10 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id s67so579330pgb.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 23:00:10 -0800 (PST)
Date: Tue, 28 Feb 2017 15:00:07 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] mm/memblock: use NUMA_NO_NODE instead of
 MAX_NUMNODES as default node_id
Message-ID: <20170228070007.GA96894@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170127015922.36249-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline
In-Reply-To: <20170127015922.36249-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi, everyone

Looking for some comment on these two patches :-)

On Fri, Jan 27, 2017 at 09:59:21AM +0800, Wei Yang wrote:
>According to commit <b115423357e0> ('mm/memblock: switch to use
>NUMA_NO_NODE instead of MAX_NUMNODES'), MAX_NUMNODES is not preferred as an
>node_id indicator.
>
>This patch use NUMA_NO_NODE as the default node_id for memblock.
>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>---
> arch/x86/mm/numa.c | 6 +++---
> mm/memblock.c      | 8 ++++----
> 2 files changed, 7 insertions(+), 7 deletions(-)
>
>diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
>index 3f35b48d1d9d..4366242356c5 100644
>--- a/arch/x86/mm/numa.c
>+++ b/arch/x86/mm/numa.c
>@@ -506,7 +506,7 @@ static void __init numa_clear_kernel_node_hotplug(void)
> 	 *   reserve specific pages for Sandy Bridge graphics. ]
> 	 */
> 	for_each_memblock(reserved, mb_region) {
>-		if (mb_region->nid !=3D MAX_NUMNODES)
>+		if (mb_region->nid !=3D NUMA_NO_NODE)
> 			node_set(mb_region->nid, reserved_nodemask);
> 	}
>=20
>@@ -633,9 +633,9 @@ static int __init numa_init(int (*init_func)(void))
> 	nodes_clear(node_online_map);
> 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
> 	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.memory,
>-				  MAX_NUMNODES));
>+				  NUMA_NO_NODE));
> 	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.reserved,
>-				  MAX_NUMNODES));
>+				  NUMA_NO_NODE));
> 	/* In case that parsing SRAT failed. */
> 	WARN_ON(memblock_clear_hotplug(0, ULLONG_MAX));
> 	numa_reset_distance();
>diff --git a/mm/memblock.c b/mm/memblock.c
>index d0f2c9632187..7d27566cee11 100644
>--- a/mm/memblock.c
>+++ b/mm/memblock.c
>@@ -292,7 +292,7 @@ static void __init_memblock memblock_remove_region(str=
uct memblock_type *type, u
> 		type->regions[0].base =3D 0;
> 		type->regions[0].size =3D 0;
> 		type->regions[0].flags =3D 0;
>-		memblock_set_region_node(&type->regions[0], MAX_NUMNODES);
>+		memblock_set_region_node(&type->regions[0], NUMA_NO_NODE);
> 	}
> }
>=20
>@@ -616,7 +616,7 @@ int __init_memblock memblock_add(phys_addr_t base, phy=
s_addr_t size)
> 		     (unsigned long long)base + size - 1,
> 		     0UL, (void *)_RET_IP_);
>=20
>-	return memblock_add_range(&memblock.memory, base, size, MAX_NUMNODES, 0);
>+	return memblock_add_range(&memblock.memory, base, size, NUMA_NO_NODE, 0);
> }
>=20
> /**
>@@ -734,7 +734,7 @@ int __init_memblock memblock_reserve(phys_addr_t base,=
 phys_addr_t size)
> 		     (unsigned long long)base + size - 1,
> 		     0UL, (void *)_RET_IP_);
>=20
>-	return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, =
0);
>+	return memblock_add_range(&memblock.reserved, base, size, NUMA_NO_NODE, =
0);
> }
>=20
> /**
>@@ -1684,7 +1684,7 @@ static void __init_memblock memblock_dump(struct mem=
block_type *type, char *name
> 		size =3D rgn->size;
> 		flags =3D rgn->flags;
> #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>-		if (memblock_get_region_node(rgn) !=3D MAX_NUMNODES)
>+		if (memblock_get_region_node(rgn) !=3D NUMA_NO_NODE)
> 			snprintf(nid_buf, sizeof(nid_buf), " on node %d",
> 				 memblock_get_region_node(rgn));
> #endif
>--=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--Kj7319i9nmIyA2yE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYtR/3AAoJEKcLNpZP5cTdCHsP/iwAeeWAtxVnLmvNEY5Z1Dav
usnZYHy2JGqlNJEEg8kyYLw2qHnF7NKYD2/GqAi8QGy3Emznq1m+HiigkDl8D2Py
8IGbu0lrTfn+0mqqDruyaWr8TMUVJzCTmFEuvT4UsTEr4Mz9+rlAcoFrq+zG0gmm
z3nqdsy4QFQMw3+AHjMfHNI6CJMRkzFnDZOlw0Uw0+TkvsA/kU2wvFSwhXJU4kDv
d+4no1j7PDNDpbrpKP5NmaFAsgQwZzHSW9x8fKXYcUSra8pLeaqNXQevhnyL+mqO
kUpsiQj8RvWBuEFz9J6POYyYuSWy7CxS2pigO9Z1fOf6J2MiU2fpOM/5El2nYpmX
B6HpI7IEbXBq0/HkAJPldI+kfLHbAyS7R502E3dEeStmYBECF/KNoBqIEsMwcas1
qSlatC9p2Lhp8njSsE+OdkPdL2ZS64Bsh3FuU889gWZr8OjvGE3PQck/Yt3PVODD
hQvLrNjx5faCvUjGrcdkjnKHYl4Pm4Al+9FFzz9xUZrcXlI9znpyQsaQbqfUSSbY
ZygOL8YsqscYAFXHL5y+pDfIVSfH2vK64PCzZ8Vzg2KTYXt1WL5F35rH77ViXFu8
8RvIpp80uGxtX84MpA5Os1bdYsAWZTDBlnsiVcmlZqoTWrEpflXhxzWoMMbp6EW0
OiWr4BU7dafXu1HGEa9P
=PlKT
-----END PGP SIGNATURE-----

--Kj7319i9nmIyA2yE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
