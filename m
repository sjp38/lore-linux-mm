Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2517B900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 20:45:18 -0400 (EDT)
Date: Thu, 23 Jun 2011 10:45:07 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2011-06-22-13-05 uploaded
Message-Id: <20110623104507.2e36aff3.sfr@canb.auug.org.au>
In-Reply-To: <201106222042.p5MKgiEe025352@imap1.linux-foundation.org>
References: <201106222042.p5MKgiEe025352@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__23_Jun_2011_10_45_07_+1000_F.rCzXwPR3mmD=X+"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--Signature=_Thu__23_Jun_2011_10_45_07_+1000_F.rCzXwPR3mmD=X+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, 22 Jun 2011 13:05:19 -0700 akpm@linux-foundation.org wrote:
>
> The mm-of-the-moment snapshot 2011-06-22-13-05 has been uploaded to
>=20
>    http://userweb.kernel.org/~akpm/mmotm/
> It contains the following patches against 3.0-rc4:
>=20
> memcg-fix-node_start-end_pfn-definition-for-mm-page_cgroupc.patch
> mm-move-vmtruncate_range-to-truncatec.patch
> mm-move-shmem-prototypes-to-shmem_fsh.patch
> tmpfs-take-control-of-its-truncate_range.patch
> tmpfs-add-shmem_read_mapping_page_gfp.patch
> drivers-rtc-rtc-ds1307c-add-support-for-rtc-device-pt7c4338.patch
> um-add-asm-percpuh.patch
> romfs-fix-romfs_get_unmapped_area-param-check.patch
> include-linux-compath-declare-compat_sys_sendmmsg.patch
> drivers-misc-lkdtmc-fix-race-when-crashpoint-is-hit-multiple-times-before=
-checking-count.patch
> mm-memory-failurec-fix-spinlock-vs-mutex-order.patch
> mm-fix-assertion-mapping-nrpages-=3D=3D-0-in-end_writeback.patch
> taskstats-dont-allow-duplicate-entries-in-listener-mode.patch
> drm-ttm-use-shmem_read_mapping_page.patch
> drm-i915-use-shmem_read_mapping_page.patch
> drm-i915-use-shmem_truncate_range.patch
> drm-i915-more-struct_mutex-locking.patch
> drm-i915-more-struct_mutex-locking-fix.patch
> mm-cleanup-descriptions-of-filler-arg.patch
> mm-truncate-functions-are-in-truncatec.patch
> mm-tidy-vmtruncate_range-and-related-functions.patch
> mm-consistent-truncate-and-invalidate-loops.patch
> mm-pincer-in-truncate_inode_pages_range.patch
> tmpfs-no-need-to-use-i_lock.patch
> mm-nommuc-fix-remap_pfn_range.patch

As an experiment, I have applied all the above patches (everything
between origin.patch and linux-next.patch exclusive) to my "fixes" tree
so that they will be in linux-next immediately after Linus' tree and
before anything else.   I am assuming that these patches are going to be
sent to Linus shortly (if you haven't already).   I will point the
akpm-start branch of linux-next to be just after the above patches (so
akpm-start..akpm-end will contain everything else in linux-next).

If this is a problem, let me know and I will drop them again.  Otherwise,
they will disappear from my tree when Linus' takes tham from you.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__23_Jun_2011_10_45_07_+1000_F.rCzXwPR3mmD=X+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOAoyTAAoJEDMEi1NhKgbsXwkH/i1LRBuijfkhvDt8nd/nn8kW
fOit5iPolvf9uQQBmoCVUm3rNVKwJWUAN+/MvSkzkkRJzZBLNe8VIYtIRQ7F9zyg
idQE5UdeLDKRrRZHaD5FWLIcnNbjs4XDmZTioI/pGSb1j6f4wRSRy7/elmCzzaK9
CBj6rDf8qMYtvBxlovnpzfgnwX7cW6It3aAGnIiN+mefq6xUximKkAHWIMAYooh8
lOuKqkLtpa2VZOB9qLJFi8Gu0PMRYP9ulUJynSsMpkTa0zOgA5v62qk3evt71Fi4
SGQzd8+XtkWj+xwfmlcp1TFG75T+A3vsZTl+WPZIB95mgV2crycmjjtg1JLMHVk=
=6m6T
-----END PGP SIGNATURE-----

--Signature=_Thu__23_Jun_2011_10_45_07_+1000_F.rCzXwPR3mmD=X+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
