Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D776E6B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 13:16:51 -0500 (EST)
Received: by pvc30 with SMTP id 30so348077pvc.14
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 10:16:50 -0800 (PST)
Date: Wed, 8 Dec 2010 11:16:44 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [1/7,v8] NUMA Hotplug Emulator: documentation
Message-ID: <20101208181644.GA2152@mgebm.net>
References: <20101207010033.280301752@intel.com>
 <20101207010139.681125359@intel.com>
 <20101207182420.GA2038@mgebm.net>
 <20101207232000.GA5353@shaohui>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2oS5YaxWCcQjTEyO"
Content-Disposition: inline
In-Reply-To: <20101207232000.GA5353@shaohui>
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Cc: shaohui.zheng@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Shaohui,

I was able to online a cpu to node 0 successfully.  My problem was that I d=
id
not take the cpu offline before I released it.  Everything looks to be work=
ing
for me.

Thanks for your help,
Eric
On Wed, 08 Dec 2010, Shaohui Zheng wrote:

> On Tue, Dec 07, 2010 at 11:24:20AM -0700, Eric B Munson wrote:
> > Shaohui,
> >=20
> > The documentation patch seems to be stale, it needs to be updated to ma=
tch the
> > new file names.
> >=20
> Eric,
> 	the major change on the patchset is on the interface, for the v8 emulato=
r,
> we accept David's per-node debugfs add_memory interface, we already inclu=
ded
> in the documentation patch. the change is very small, so it is not obviou=
s.
>=20
> This is the change on the documentation compare with v7:
> +3) Memory hotplug emulation:
> +
> +The emulator reserves memory before OS boots, the reserved memory region=
 is
> +removed from e820 table. Each online node has an add_memory interface, a=
nd
> +memory can be hot-added via the per-ndoe add_memory debugfs interface.
> +
> +The difficulty of Memory Release is well-known, we have no plan for it u=
ntil
> +now.
> +
> + - reserve memory thru a kernel boot paramter
> + 	mem=3D1024m
> +
> + - add a memory section to node 3
> +    # echo 0x40000000 > mem_hotplug/node3/add_memory
> +	OR
> +    # echo 1024m > mem_hotplug/node3/add_memory
> +
>=20
> --=20
> Thanks & Regards,
> Shaohui
>=20

--2oS5YaxWCcQjTEyO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJM/8uMAAoJEH65iIruGRnNYS8IAK4GQMrZXfwz5nmtvFrBpbfj
VAqUR67okBDzpKM1z3RHnueQNQFOByV29zH+b0rk1R3q1kk6BHoIui1gGBE/W/rF
gIVM+ozPYtPKnf9ogjivgqlu5nXh8E5e6TkSvLheO8idr3UgqE0jmb1bOQ3ZI0Hy
Gf3w2pWTJQDOgTJGQspOdEGaW322h/qDpLnizDA6aL0PFKuxPWwTdW7jS7jfhpxp
SpeY/paJFe8fZuxjI49IWx+GMTH0PvMhYprMqswMWT2CTqlT094jg0iy3sF2C+Bv
2S07qou0e6v3b8OMnGWXEGZwiwMxfpQJWwR6kuBEg9hJxi8ruusRN8K1J9L9XN8=
=AHrM
-----END PGP SIGNATURE-----

--2oS5YaxWCcQjTEyO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
