Date: Tue, 9 Sep 2003 00:02:13 -0700
Subject: Re: 2.6.0-test5-mm1
Message-ID: <20030909070213.GF7314@triplehelix.org>
References: <20030908235028.7dbd321b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ylS2wUBXLOxYXZFQ"
Content-Disposition: inline
In-Reply-To: <20030908235028.7dbd321b.akpm@osdl.org>
From: Joshua Kwan <joshk@triplehelix.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

--ylS2wUBXLOxYXZFQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 08, 2003 at 11:50:28PM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test5=
/2.6.0-test5-mm1/

Needs the following patch to compile:

--- mm/slab.c~	2003-09-08 23:58:31.000000000 -0700
+++ mm/slab.c	2003-09-08 23:58:33.000000000 -0700
@@ -2794,11 +2794,13 @@
 		} else {
 			kernel_map_pages(virt_to_page(objp), c->objsize/PAGE_SIZE, 1);
=20
+#if DEBUG
 			if (c->flags & SLAB_RED_ZONE)
 				printk("redzone: 0x%lx/0x%lx.\n", *dbg_redzone1(c, objp), *dbg_redzone=
2(c, objp));
=20
 			if (c->flags & SLAB_STORE_USER)
 				printk("Last user: %p.\n", *dbg_userword(c, objp));
+#endif
 		}
 		spin_unlock_irqrestore(&c->spinlock, flags);
=20
--=20
Joshua Kwan

--ylS2wUBXLOxYXZFQ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iQIVAwUBP1169KOILr94RG8mAQIpNw//V2KYJYMvmqsDNJeud+vFwSzEZ2aZlxIN
1fan4Y3hFjzdY2ftyi989DFRHvrVxOmDq7Nw59fIQq0VhGkDYrjvmC8RuOh8tae3
pkfG6UngtqlsJe7GEVaGO+fkQfvCNdlcn5ps74Jaja3Isb2NqFA/pHk3cG8/T34U
dwz6QunpxA7kQ2joptbqaD5sIUkAQ/bq2wEQHPS1OyV3rTzbPsYICbwqCbsjqPAl
WwHulOoyqGSbbFxihUYJv9f35odZ8GEsaeD8+kZ/nHkjWbK2MAJyn+xjmE/DM+5h
qnJFjAjzpCCTHSDZSZhbbvsFV8uukOzjIDiEaYIoPaiGMeaPQF/YR4wOTOfNxoUK
dDQ3ni5Le8MSR2ewqmLCud22jj579KSv4LOKSTv4kx/sjHerTxe3vHHd8DOPKKY/
owvr+qKR9aArIEOkBzCFV9hxgzRz52jhAgAlWIhMgFwsL8ScPK1sZ+EHKZossaJe
5a6Tb3E1//hO2yspiAC1pEPae9+sZMauK8X8Pu73BuiVisfdz66OEcpCMLBViIKn
u4o3ONg1r+manRq2zLswzgXMsJjCsuC4Tw+vEj/zBg6fkjmNCaWraF+TiKOve+ZY
p6bP91pMSpeaXppMb9Mfl4EYmXofv3lu8qcPEzHCcSPQuoeSk43KLm+XAW6CuFix
1EcBiNUfcEg=
=/7Vh
-----END PGP SIGNATURE-----

--ylS2wUBXLOxYXZFQ--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
