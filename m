Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8F97B6B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 17:12:04 -0500 (EST)
Received: by mail-qk0-f171.google.com with SMTP id o6so24873008qkc.2
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:12:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d9si11846688qkb.119.2016.02.11.14.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 14:12:03 -0800 (PST)
Message-ID: <1455228719.15821.18.camel@redhat.com>
Subject: Re: computing drop-able caches
From: Rik van Riel <riel@redhat.com>
Date: Thu, 11 Feb 2016 17:11:59 -0500
In-Reply-To: <56BB8B5E.0@cisco.com>
References: <56AAA77D.7090000@cisco.com> <20160128235815.GA5953@cmpxchg.org>
	 <56AABA79.3030103@cisco.com> <56AAC085.9060509@cisco.com>
	 <20160129015534.GA6401@cmpxchg.org> <56ABEAA7.1020706@redhat.com>
	 <D2DE3289.2B1F3%khalidm@cisco.com> <56BB7BC7.4040403@cisco.com>
	 <56BB7DDE.8080206@intel.com> <56BB8B5E.0@cisco.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-BpeyX5zFj02UhucDDNKq"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>, Dave Hansen <dave.hansen@intel.com>, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>


--=-BpeyX5zFj02UhucDDNKq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-02-10 at 11:11 -0800, Daniel Walker wrote:
> On 02/10/2016 10:13 AM, Dave Hansen wrote:
> > On 02/10/2016 10:04 AM, Daniel Walker wrote:
> > > > [Linux_0:/]$ echo 3 > /proc/sys/vm/drop_caches
> > > > [Linux_0:/]$ cat /proc/meminfo
> > > > MemTotal:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A03977836 kB
> > > > MemFree:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A010950=
12 kB
> > > > MemAvailable:=C2=A0=C2=A0=C2=A0=C2=A01434148 kB
> > > I suspect MemAvailable takes into account more than just the
> > > droppable
> > > caches. For instance, reclaimable slab is included, but I don't
> > > think
> > > drop_caches drops that part.
> > There's a bit for page cache and a bit for slab, see:
> >=20
> > 	https://kernel.org/doc/Documentation/sysctl/vm.txt
> >=20
> >=20
>=20
> Ok, then this looks like a defect then. I would think MemAvailable
> would=C2=A0
> always be smaller then MemFree (after echo 3 >=C2=A0
> /proc/sys/vm/drop_caches).. Unless there is something else be
> accounted=C2=A0
> for that we aren't aware of.

echo 3 > /proc/sys/vm/drop_caches will only
drop unmapped page cache, IIRC

The system may still have a number of page
cache pages left that are mapped in processes,
but will be reclaimable if the VM needs the
memory for something else.

--=C2=A0
All rights reversed

--=-BpeyX5zFj02UhucDDNKq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJWvQcvAAoJEM553pKExN6D8M8H/0Aqc7NwsoGFLS80k46ifXkN
+zNxiikPvml92gDEVmhQ1oU0k06+qOEXO+rF2zpdCS0vDsV0+smzBS4KV1sWENmA
7x03R0J3G4b4G9UMZilcxGusu/zGaHP9X3Tajd2QDRy6SzzdMirC0ajtYZ2ZlOAs
qDsjuNp1fcdDVCuovM6HUUFN2nhdqSDzXdrt02ax9Xzobsq21vtjPOmzmemz0rqP
LhO6mITER0Bo3uVAI5JZ/VChWA7aNRDb2Hlz6cyNE2P+QUsmKy7iVodi4xWIiRPc
EO3TKpIXeJfo56+lAvibNJWrYBR7hQCluS9fEnCG29MTlYzIQlAjX/SIySD/F8U=
=9Tdh
-----END PGP SIGNATURE-----

--=-BpeyX5zFj02UhucDDNKq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
