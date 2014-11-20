Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 035F36B0069
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 22:31:03 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so1622697pad.23
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 19:31:02 -0800 (PST)
Received: from ponies.io (mail.ponies.io. [173.255.217.209])
        by mx.google.com with ESMTP id e16si1209718pdj.196.2014.11.19.19.31.00
        for <linux-mm@kvack.org>;
        Wed, 19 Nov 2014 19:31:01 -0800 (PST)
Received: from cucumber.localdomain (58-6-54-190.dyn.iinet.net.au [58.6.54.190])
	by ponies.io (Postfix) with ESMTPSA id 534F4A0BB
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 03:31:00 +0000 (UTC)
Date: Thu, 20 Nov 2014 14:30:57 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141120033057.GA28899@cucumber.anchor.net.au>
References: <20141119012110.GA2608@cucumber.iinet.net.au>
 <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
 <20141119212013.GA18318@cucumber.anchor.net.au>
 <546D2366.1050506@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="X1bOJ3K7DJ5YkBrT"
Content-Disposition: inline
In-Reply-To: <546D2366.1050506@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 20, 2014 at 12:10:30AM +0100, Vlastimil Babka wrote:
> > Is this fixed in a later kernel? I haven't tested yet.
>=20
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

Excellent, thankyou.

I realised there were a lot of changes but this list of specific fixes might
help narrow down the actual cause here. I've just built a kernel that's exa=
ctly
the same as the exploding one with just these three patches and will be back
tomorrow with the results of testing.

--X1bOJ3K7DJ5YkBrT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUbWBxAAoJEMHZnoZn5OShQi4QAJB4H/2aEHsDVllX+AL1O5jH
i2R994mXxAT0yqKn3z32/ZyG1PTcPHFeJ3hvMoJiWtKCSyAV3TSTzbg2Bdw09P+x
hckV+M6kxb85OmscaqlBmE0xe/YdC3LtAL0h3C3NzbVUh2JFKMjMOTG93Qehfryb
D6joYtCOQqHpYl5OFrIyIVxZrHjTIGVEhUT1GMWTRBrcCMPDPphVaurbrv/Mfbwd
ADOI4IqK9xDbI/feTj+kY6n+ylSJOO3rm5eGoDEWIc8eXWxFloHlaIJqqOWuFoS0
yLJGUvVBtNJtKWmWm59bM1EpUYhh2ISkxatiwhaVzUXp8WYT7hb0ejafUaDX15rI
XRZC3laDZGCv03RC+n8WA3oL/cKUjkNwl4L7FW8D4AO5PckeUcB3d3l9AaFdNMHE
lOiOv71IALAitEZDAEl7kj0Jsh30ggJ7GsAEwkoqGnlzhjsq+TpKZlAuDcwB/fpo
pkG1y+sgY7dBiw93cN9I4PGObUxUnWZzphIUHLp0sNPulnn+2jNVDs1BNGcGqjgS
uAqvri9C1g3BAReH22nAJ9Nm6xNw7AM07fblWzlGY+oQVSzkMVB3RdK4sbiHFksJ
DXxgxfiss0ViQETB8PO39QzP10cO6kXKWrSelFKAfiu8WYfnFYXjhasF7fb4+YvC
mFMS5alSpaNu9gq2z+XY
=ydAx
-----END PGP SIGNATURE-----

--X1bOJ3K7DJ5YkBrT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
