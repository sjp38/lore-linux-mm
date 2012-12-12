Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 39BB06B0081
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 05:49:58 -0500 (EST)
Date: Wed, 12 Dec 2012 12:51:09 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] huge_memory: fix huge zero page refcount
Message-ID: <20121212105109.GA14101@otc-wbsnb-06>
References: <1355294677-26842-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fdj2RfSjLxBAspz7"
Content-Disposition: inline
In-Reply-To: <1355294677-26842-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, rientjes@google.com, linux-mm@kvack.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 12, 2012 at 02:44:37PM +0800, Bob Liu wrote:
> Hi Andrew,
>=20
> It seems patch "[PATCH v5 10/11] thp: implement refcounting for huge zero
> page" was merged wrong into your tree.
>=20
> In Kirill's patch, put_huge_zero_page() is called in
> do_huge_pmd_wp_zero_page_fallback().
> But in linux-next and linux-mmotm.git, it's called in
> do_huge_pmd_wp_page_fallback().
>=20
> That's wrong and make below BUG triggered again:
>=20
> [ 1384.485993] ------------[ cut here ]------------
> [ 1384.486031] kernel BUG at mm/huge_memory.c:213!
> [ 1384.486055] invalid opcode: 0000 [#1] PREEMPT SMP
> .....
> 3.7.0-rc8+ #53 Dell Inc. OptiPlex 760                 /0M860N
> [ 1384.486473] EIP: 0060:[<c114d9d8>] EFLAGS: 00010202 CPU: 1
> [ 1384.486504] EIP is at put_huge_zero_page+0x18/0x20
> [ 1384.486528] EAX: 00000001 EBX: 00000008 ECX: 00000000 EDX: ed5c4000
> [ 1384.486556] ESI: b5a00000 EDI: ed7af000 EBP: ed5c5e8c ESP: ed5c5e8c
> [ 1384.486585]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [ 1384.486611] CR0: 8005003b CR2: b59ffba8 CR3: 2e79a000 CR4: 000427f0
> [ 1384.486639] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> [ 1384.486668] DR6: ffff0ff0 DR7: 00000400
> [ 1384.486687] Process gnome-terminal (pid: 12714, ti=3Ded5c4000 task=3De=
bd59a60
> task.ti=3Ded5c4000)
> [ 1384.486724] Stack:
> [ 1384.486735]  ed5c5eec c1151329 092fb067 80000000 eaf9eca8 ed7ae800 ed7=
ae800
> 2c6f9000
> [ 1384.486786]  00000000 f5ff16e8 f251d378 00000163 b5a00000 f4622000 b58=
00000
> f251d340
> [ 1384.486836]  ec7b6c60 80000000 092fb067 2c6f9067 00000000 c74000c5 800=
00000
> eaf9ed60
> [ 1384.486887] Call Trace:
> [ 1384.486902]  [<c1151329>] do_huge_pmd_wp_page+0x949/0xb60
> [ 1384.486929]  [<c1128aff>] handle_mm_fault+0x14f/0x330
> [ 1384.486956]  [<c1804810>] ? __do_page_fault+0x550/0x550
> [ 1384.486981]  [<c180440d>] __do_page_fault+0x14d/0x550
> [ 1384.487005]  [<c180481d>] ? do_page_fault+0xd/0x10
> [ 1384.487030]  [<c1801cdf>] ? error_code+0x67/0x6c
> [ 1384.487054]  [<c180007b>] ? __schedule+0x66b/0x7c0
> [ 1384.487080]  [<c12ea155>] ? __put_user_4+0x11/0x18
> [ 1384.487104]  [<c1804810>] ? __do_page_fault+0x550/0x550
> [ 1384.487130]  [<c180481d>] do_page_fault+0xd/0x10
> [ 1384.487153]  [<c1801cdf>] error_code+0x67/0x6c
> [ 1384.487176]  [<c1800000>] ? __schedule+0x5f0/0x7c0
>=20
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

--=20
 Kirill A. Shutemov

--fdj2RfSjLxBAspz7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQyGGdAAoJEAd+omnVudOMtUwP/1EIrAJrFoLlXL6Bjz77zGRU
MAsMu3SLVbymi+8xsL1k9ai/IACWtAzY6fXcIMKFBK4GmUvv+c2pHMGOZqYC+M9J
rKF9CJLWNSAo/K9bTPHxzYHZeiYWN4vHVrNH49o43srl9cOYm9HaQe1CjDEA/0zN
XJJBXgf58j+LQVrzt7qG2kXnZs9Q/lGX52nx8d8JyttKFcqIETnauQtRzUxbve8L
Vka6cPBQd2nqY11EFy5778QJxvI1pGnqdlVoqm8+/H+DqyWPQtKhxlmQXhfYLThB
1qcpbBwA8MIPSCF+6AcM4DPamrjlCAT3LOyB4bfeIPFv5CSo4tas0rBfDeoLyURv
yZcZJ7QFm29WGGRzEuYgZXOAca5D5OQtZdv0u4Hy8cilluvKJFy2/mLRrMmQEnZW
4BSYnaidYkgf60sZE74pnl+Y/5ugnbBV+RWRDfA2vsZYRJ+CLQ4CaJDQLFJak1FP
BniEhrHS5QwBInhE1znI6t1nV3ACGg7KG9jrq7j0/x/umoZ1NqhXOLb3nfwlh/uo
dTs0+ukbSBziUFbaf1vqSteVITNFDJbpOSmHK0OOe5+zibJMcVNWrPjFD0kr+RRP
UGsAJ6nDlChQK8ha/d9sJ9VTg6eAR+tSTDeqoeYB/mvu7SFNx9b8GiFYQm0ciwpU
ZRcIpsbmKt/In1SeRKdn
=iQwT
-----END PGP SIGNATURE-----

--fdj2RfSjLxBAspz7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
