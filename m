Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 53EB46B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 13:14:14 -0500 (EST)
Received: by gxk24 with SMTP id 24so2386828gxk.6
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 10:14:12 -0800 (PST)
Message-ID: <4AF072EE.9020202@gmail.com>
Date: Tue, 03 Nov 2009 13:14:06 -0500
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
References: <cover.1257267892.git.mst@redhat.com> <20091103172422.GD5591@redhat.com> <4AF0708B.4020406@gmail.com> <4AF07199.2020601@gmail.com>
In-Reply-To: <4AF07199.2020601@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE18A8C89AC1232EB011669F5"
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE18A8C89AC1232EB011669F5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Gregory Haskins wrote:
> Eric Dumazet wrote:
>> Michael S. Tsirkin a =E9crit :
>>> +static void handle_tx(struct vhost_net *net)
>>> +{
>>> +	struct vhost_virtqueue *vq =3D &net->dev.vqs[VHOST_NET_VQ_TX];
>>> +	unsigned head, out, in, s;
>>> +	struct msghdr msg =3D {
>>> +		.msg_name =3D NULL,
>>> +		.msg_namelen =3D 0,
>>> +		.msg_control =3D NULL,
>>> +		.msg_controllen =3D 0,
>>> +		.msg_iov =3D vq->iov,
>>> +		.msg_flags =3D MSG_DONTWAIT,
>>> +	};
>>> +	size_t len, total_len =3D 0;
>>> +	int err, wmem;
>>> +	size_t hdr_size;
>>> +	struct socket *sock =3D rcu_dereference(vq->private_data);
>>> +	if (!sock)
>>> +		return;
>>> +
>>> +	wmem =3D atomic_read(&sock->sk->sk_wmem_alloc);
>>> +	if (wmem >=3D sock->sk->sk_sndbuf)
>>> +		return;
>>> +
>>> +	use_mm(net->dev.mm);
>>> +	mutex_lock(&vq->mutex);
>>> +	vhost_no_notify(vq);
>>> +
>> using rcu_dereference() and mutex_lock() at the same time seems wrong,=
 I suspect
>> that your use of RCU is not correct.
>>
>> 1) rcu_dereference() should be done inside a read_rcu_lock() section, =
and
>>    we are not allowed to sleep in such a section.
>>    (Quoting Documentation/RCU/whatisRCU.txt :
>>      It is illegal to block while in an RCU read-side critical section=
, )
>>
>> 2) mutex_lock() can sleep (ie block)
>>
>=20
>=20
> Michael,
>   I warned you that this needed better documentation ;)
>=20
> Eric,
>   I think I flagged this once before, but Michael convinced me that it
> was indeed "ok", if but perhaps a bit unconventional.  I will try to
> find the thread.
>=20
> Kind Regards,
> -Greg
>=20

Here it is:

http://lkml.org/lkml/2009/8/12/173

Kind Regards,
-Greg


--------------enigE18A8C89AC1232EB011669F5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkrwcu4ACgkQP5K2CMvXmqH6LQCfYPH0ZOpy6lFQqLyJiRpczJJt
1L4Anjn/hFabGiOof5cYTbyAv9fZr2fM
=UyNc
-----END PGP SIGNATURE-----

--------------enigE18A8C89AC1232EB011669F5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
