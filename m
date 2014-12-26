Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA5A6B0038
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 16:11:54 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id q200so5168430ykb.7
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 13:11:54 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id t28si948296yhg.40.2014.12.26.13.11.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Dec 2014 13:11:53 -0800 (PST)
Date: Fri, 26 Dec 2014 15:10:55 -0600
From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 00/38] mm: remove non-linear mess
Message-ID: <20141226211055.GM17430@saruman>
Reply-To: <balbi@ti.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="q8dntDJTu318bll0"
Content-Disposition: inline
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

--q8dntDJTu318bll0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 24, 2014 at 02:22:08PM +0200, Kirill A. Shutemov wrote:
> We have remap_file_pages(2) emulation in -mm tree for few release cycles
> and we plan to have it mainline in v3.20. This patchset removes rest of
> VM_NONLINEAR infrastructure.
>=20
> Patches 1-8 take care about generic code. They are pretty
> straight-forward and can be applied without other of patches.
>=20
> Rest patches removes pte_file()-related stuff from architecture-specific
> code. It usually frees up one bit in non-present pte. I've tried to reuse
> that bit for swap offset, where I was able to figure out how to do that.
>=20
> For obvious reason I cannot test all that arch-specific code and would
> like to see acks from maintainers.
>=20
> In total, remap_file_pages(2) required about 1.4K lines of not-so-trivial
> kernel code. That's too much for functionality nobody uses.
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git remap_file_pa=
ges

have been running this for a while on a three different ARM boards I
have around, haven't noticed anything wrong.

Tested-by: Felipe Balbi <balbi@ti.com>

--=20
balbi

--q8dntDJTu318bll0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUnc7fAAoJEIaOsuA1yqREWbsQAIONHDDofx75YXCcFBBg1zDy
idy1wuwS2Dk3Po1MGqXvAo/xwmAVTI1xq6cDSyz16gUYnWc553l1seeSIHU0AnON
Vz5Ik/Hhdnm7S4z2bDWFmsLDyEq5OH7MSc31GvTnKNPXUs0ZXqp58kiGDxQHN4JN
5qrEVYhkqNWKsONprnZ0Tu4lTkz8fZb1hY2tBeBEeyJFrxTmgVwMavcEk8is3Fwm
M2vibrHWSMyBlBl6daPV9aCoqdcxFnwdW+g0TILL7u7tWJnb7HxVaSOJ9avZxQVK
lxBXvwKAWHuqZPWP9eScUWEZklpl2U3E/SDOm5156HNq3N8LFmVQUfTndARwYr1W
2hmopRMignA+EuH0fRdpUXXjv5RGZnFUWHyZkWOsYvwe0WfhBRgbE8Q4Shagn+6z
OzaH94Gg3104OCE5Ro3WITfpcbr6rUzClNtUvcfTe/8A4dAEvTKGZhdbB48LnBJp
N0/bhyU0O0MKSE51BZM7s65L5uL+cMRBQmScCCmqB0QphjvMMZy3gWuiVOn7knJg
ZSac+3mKz0I9sRFm33rB59/6QyCP3CzGk4omNiNyqdFdaHsKf7kJ5P3/nuVAeRTU
50/phJWyQsXxo5Isdgnz5Lgbx5AOeuHulaLHdTOYNVNJTmt8V0VI9tE05/kNpTHG
4SlaWuL1So+z26SMg3E9
=pBan
-----END PGP SIGNATURE-----

--q8dntDJTu318bll0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
