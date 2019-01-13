Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 65C4F8E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 18:10:15 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id l73so1995132wmb.1
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 15:10:15 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id n123si17906522wmb.157.2019.01.13.15.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 15:10:13 -0800 (PST)
Date: Mon, 14 Jan 2019 00:10:12 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCHv3 08/13] Documentation/ABI: Add node performance
 attributes
Message-ID: <20190113231012.GD18710@amd>
References: <20190109174341.19818-1-keith.busch@intel.com>
 <20190109174341.19818-9-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mSxgbZZZvrAyzONB"
Content-Disposition: inline
In-Reply-To: <20190109174341.19818-9-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>


--mSxgbZZZvrAyzONB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2019-01-09 10:43:36, Keith Busch wrote:
> Add descriptions for memory class initiator performance access attributes.
>=20

> +What:		/sys/devices/system/node/nodeX/classY/read_latency
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		This node's read latency in nanosecondss available to memory
> +		initiators in nodes found in this class's initiators_nodelist.
> +
> +What:		/sys/devices/system/node/nodeX/classY/write_bandwidth
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		This node's write bandwidth in MB/s available to memory
> +		initiators in nodes found in this class's initiators_nodelist.
> +
> +What:		/sys/devices/system/node/nodeX/classY/write_latency
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		This node's write latency in nanosecondss available to memory
> +		initiators in nodes found in this class's
> initiators_nodelist.

"nanosecondss", twice.
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--mSxgbZZZvrAyzONB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlw7xVQACgkQMOfwapXb+vKXGgCfcEUziEucdCLurHcSo0hJzfJy
bPEAmwaIAoUO698IlY0VU3WeRzDeafDq
=fjA3
-----END PGP SIGNATURE-----

--mSxgbZZZvrAyzONB--
