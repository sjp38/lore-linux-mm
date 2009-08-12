Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1C2EE6B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 07:56:02 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so1571588qwf.44
        for <linux-mm@kvack.org>; Wed, 12 Aug 2009 04:56:09 -0700 (PDT)
Message-ID: <4A82ADD5.6040909@gmail.com>
Date: Wed, 12 Aug 2009 07:56:05 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
References: <20090811212743.GA26309@redhat.com> <4A820391.1090404@gmail.com> <20090812071636.GA26847@redhat.com>
In-Reply-To: <20090812071636.GA26847@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD7605C67DFA4B328715B65EB"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, "akpm@linux-foundation.org >> Andrew Morton" <akpm@linux-foundation.org>, hpa@zytor.com, Patrick Mullaney <pmullaney@novell.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD7605C67DFA4B328715B65EB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Tue, Aug 11, 2009 at 07:49:37PM -0400, Gregory Haskins wrote:
>> Michael S. Tsirkin wrote:
>>> This implements vhost: a kernel-level backend for virtio,
>>> The main motivation for this work is to reduce virtualization
>>> overhead for virtio by removing system calls on data path,
>>> without guest changes. For virtio-net, this removes up to
>>> 4 system calls per packet: vm exit for kick, reentry for kick,
>>> iothread wakeup for packet, interrupt injection for packet.
>>>
>>> Some more detailed description attached to the patch itself.
>>>
>>> The patches are against 2.6.31-rc4.  I'd like them to go into linux-n=
ext
>>> and down the road 2.6.32 if possible.  Please comment.
>> I will add this series to my benchmark run in the next day or so.  Any=

>> specific instructions on how to set it up and run?
>>
>> Regards,
>> -Greg
>>
>=20
> 1. use a dedicated network interface with SRIOV, program mac to match
>    that of guest (for testing, you can set promisc mode, but that is
>    bad for performance)

Are you saying SRIOV is a requirement, and I can either program the
SRIOV adapter with a mac or use promis?  Or are you saying I can use
SRIOV+programmed mac OR a regular nic + promisc (with a perf penalty).


> 2. disable tso,gso,lro with ethtool

Out of curiosity, wouldnt you only need to disable LRO on the adapter,
since the other two (IIUC) are transmit path and are therefore
influenced by the skb's you generate in vhost?


> 3. add vhost=3DethX

You mean via "ip link" I assume?

Regards,
-Greg


--------------enigD7605C67DFA4B328715B65EB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqCrdUACgkQP5K2CMvXmqEOwACeNAOQtMMRFiCXlgHvg9A3/BC2
g4AAnRa44uxf7P8j1pmsxBIk2t1ehw2Q
=Khle
-----END PGP SIGNATURE-----

--------------enigD7605C67DFA4B328715B65EB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
