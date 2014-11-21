Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E1B336B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 21:35:59 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so3810419pab.5
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 18:35:59 -0800 (PST)
Received: from ponies.io (ponies.io. [2600:3c01::f03c:91ff:fe6e:5e45])
        by mx.google.com with ESMTP id ym4si6073963pab.27.2014.11.20.18.35.57
        for <linux-mm@kvack.org>;
        Thu, 20 Nov 2014 18:35:58 -0800 (PST)
Received: from cucumber.localdomain (nat-gw2.syd4.anchor.net.au [110.173.144.2])
	by ponies.io (Postfix) with ESMTPSA id 1DE88A0BF
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:35:56 +0000 (UTC)
Date: Fri, 21 Nov 2014 13:35:54 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
References: <20141119012110.GA2608@cucumber.iinet.net.au>
 <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
 <20141119212013.GA18318@cucumber.anchor.net.au>
 <546D2366.1050506@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3MwIy2ne0vdjdPXF"
Content-Disposition: inline
In-Reply-To: <546D2366.1050506@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 20, 2014 at 12:10:30AM +0100, Vlastimil Babka wrote:
> As I said, recent kernels received many compaction performance tuning pat=
ches,
> and reclaim as well. I would recommend trying them, if it's possible.
>=20
> You mention 3.10.0-123.9.3.el7.x86_64 which I have no idea how it relates=
 to
> upstream stable kernel. Upstream version 3.10.44 received several compact=
ion
> fixes that I'd deem critical for compaction to work as intended, and lack=
 of
> them could explain your problems:
>=20
> mm: compaction: reset cached scanner pfn's before reading them
> commit d3132e4b83e6bd383c74d716f7281d7c3136089c upstream.
>=20
> mm: compaction: detect when scanners meet in isolate_freepages
> commit 7ed695e069c3cbea5e1fd08f84a04536da91f584 upstream.
>=20
> mm/compaction: make isolate_freepages start at pageblock boundary
> commit 49e068f0b73dd042c186ffa9b420a9943e90389a upstream.
>=20
> You might want to check if those are included in your kernel package, and=
/or try
> upstream stable 3.10 (if you can't use the latest for some reason).

I built exactly the same kernel with these patches applied, unfortunately it
suffered the same problem. I will now try the latest (3.18-rc5) release
candidate and report back.

Do you have any ideas of where I could be looking to collect data to track =
down
what is happening here? Here is some perf output again:

http://ponies.io/raw/compaction.png

--3MwIy2ne0vdjdPXF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUbqUKAAoJEMHZnoZn5OSh+IkP/3oR4tOYU/c8Bk/duCYmpYrR
oirCo2VcQYb3EJluPFErltD/XMfoYOngsrDbrfK/anubq6ZteIHIGcxqbf5aKsdy
t2K3YKDS8IDrsrElrM6zPFIfgGJPU7H/9E7fUbtwcLjyTbzUiV6CjqLCKW8+1AJy
RZ2a+aexA/1ggPGLPS9HZTN+ODv1zGxs6HwjjTeSwiE6rcUkhOvSLUleMNRODjQB
5lxZSEhRHhKUaLzkw4iL1qB0v923GLAVxWMBZW2apQlr90F+P+VZMIVSouT74uRI
jvySWuY2DqpAVEDvN6Rf9RauxIQSVesuNX7kZVf/PLpxLQKugDOYFOl3n2571wob
pdnaxeWcLG9gBdd3byZWA2gTVbAhH59hvCF6wqkF542xkuR8UbppZ2ikcd5sQ3HI
ODhLvsZf/rEvS0onjJ/RWvhbNDP784C2UFAvRLTaQjT7r0whfM88fxxMCL0q6//p
4myjBu0j6hPrEBz4Iq7ID08kMdbEApgWwDtbv2l8ptEY3RBYpvdrZgThBTRVXSIr
roVfEAZdNeiWo/PxuhJhYTdy6wvRXKohjqCtpjeLZKHytHXvOiuYQVsVpwsNBEjK
z5x5NgWr9d5RY6cZI+kkipBcii/ZXJB5ntFJ/N5GzM8marDY3IrcnjUDtQ7KX2Wp
PxYsKuF94ZmaD4zgRlVX
=5dns
-----END PGP SIGNATURE-----

--3MwIy2ne0vdjdPXF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
