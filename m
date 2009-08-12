Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 357936B0088
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 12:13:44 -0400 (EDT)
Received: by qyk36 with SMTP id 36so110607qyk.12
        for <linux-mm@kvack.org>; Wed, 12 Aug 2009 09:13:46 -0700 (PDT)
Message-ID: <4A82EA37.3010902@gmail.com>
Date: Wed, 12 Aug 2009 12:13:43 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
References: <20090811212743.GA26309@redhat.com> <200908121452.01802.arnd@arndb.de> <20090812130612.GC29200@redhat.com> <200908121540.44928.arnd@arndb.de> <4A82C8F1.4030703@gmail.com> <20090812140224.GA29345@redhat.com>
In-Reply-To: <20090812140224.GA29345@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4E37A2FAF65F7E8AF474EC70"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com, Patrick Mullaney <pmullaney@novell.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4E37A2FAF65F7E8AF474EC70
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Wed, Aug 12, 2009 at 09:51:45AM -0400, Gregory Haskins wrote:
>> Arnd Bergmann wrote:
>>> On Wednesday 12 August 2009, Michael S. Tsirkin wrote:
>>>>> If I understand it correctly, you can at least connect a veth pair
>>>>> to a bridge, right? Something like
>>>>>
>>>>>            veth0 - veth1 - vhost - guest 1=20
>>>>> eth0 - br0-|
>>>>>            veth2 - veth3 - vhost - guest 2
>>>>>           =20
>>>> Heh, you don't need a bridge in this picture:
>>>>
>>>> guest 1 - vhost - veth0 - veth1 - vhost guest 2
>>> Sure, but the setup I described is the one that I would expect
>>> to see in practice because it gives you external connectivity.
>>>
>>> Measuring two guests communicating over a veth pair is
>>> interesting for finding the bottlenecks, but of little
>>> practical relevance.
>>>
>>> 	Arnd <><
>> Yeah, this would be the config I would be interested in.
>=20
> Hmm, this wouldn't be the config to use for the benchmark though: there=

> are just too many variables.  If you want both guest to guest and guest=

> to host, create 2 nics in the guest.
>=20
> Here's one way to do this:
>=20
> 	-net nic,model=3Dvirtio,vlan=3D0 -net user,vlan=3D0
> 	-net nic,vlan=3D1,model=3Dvirtio,vhost=3Dveth0
> 	-redir tcp:8022::22
>=20
> 	-net nic,model=3Dvirtio,vlan=3D0 -net user,vlan=3D0
> 	 -net nic,vlan=3D1,model=3Dvirtio,vhost=3Dveth1
> 	-redir tcp:8023::22
>=20
> In guests, for simplicity, configure eth1 and eth0
> to use separate subnets.

I can try to do a few variations, but what I am interested is in
performance in a real-world L2 configuration.  This would generally mean
 all hosts (virtual or physical) in the same L2 domain.

If I get a chance, though, I will try to also wire them up in isolation
as another data point.

Regards,
-Greg



--------------enig4E37A2FAF65F7E8AF474EC70
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqC6jcACgkQP5K2CMvXmqG0FQCfVhCkLU4jF4NKuVMP5GrYh+cH
NF4AoIqK9SqEu0RYq/LqHoplHQBbErgz
=ydLy
-----END PGP SIGNATURE-----

--------------enig4E37A2FAF65F7E8AF474EC70--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
