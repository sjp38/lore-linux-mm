Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE896B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 20:47:29 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so12033167pdb.18
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 17:47:28 -0800 (PST)
Received: from ponies.io (ponies.io. [2600:3c01::f03c:91ff:fe6e:5e45])
        by mx.google.com with ESMTP id fa6si31503905pab.53.2014.12.01.17.47.26
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 17:47:27 -0800 (PST)
Received: from cucumber.localdomain (nat-gw2.syd4.anchor.net.au [110.173.144.2])
	by ponies.io (Postfix) with ESMTPSA id 76BF7A0F1
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 01:47:26 +0000 (UTC)
Date: Tue, 2 Dec 2014 12:47:24 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
References: <20141119012110.GA2608@cucumber.iinet.net.au>
 <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
 <20141119212013.GA18318@cucumber.anchor.net.au>
 <546D2366.1050506@suse.cz>
 <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
 <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="lrZ03NoBR/3+SXJZ"
Content-Disposition: inline
In-Reply-To: <20141201083118.GB2499@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 28.11.2014 9:03, Joonsoo Kim wrote:
> Hello,
>
> I didn't follow-up this discussion, but, at glance, this excessive CPU
> usage by compaction is related to following fixes.
>
> Could you test following two patches?
>
> If these fixes your problem, I will resumit patches with proper commit
> description.
>
> -------- 8< ---------


Thanks for looking into this. Running 3.18-rc5 kernel with your patches has
produced some interesting results.

Load average still spikes to around 2000-3000 with the processors spinning 100%
doing compaction related things when min_free_kbytes is left at the default.

However, unlike before, the system is now completely stable. Pre-patch it would
be almost completely unresponsive (having to wait 30 seconds to establish an
SSH connection and several seconds to send a character).

Is it reasonable to guess that ipoib is giving compaction a hard time and
fixing this bug has allowed the system to at least not lock up?

I will try back-porting this to 3.10 and seeing if it is stable under these
strange conditions also.

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUfRoqAAoJEMHZnoZn5OShnbQP/juGp0cJ6pASeWsH/JyN6+ru
wT9FvL7IMopc/YM0VXz3vX1P4sz2jJKrnrgucbWXYlssQ3L5q2Epw27rz3tU5Kj+
7czx7m3CqkEh854IRtLEUA8OlHyT3EsO5KUFUuMzVojfDcNjbx/In4EtSdSVN+4z
7ujOtUZvkXYs3d4QN6RVzx27oPmX9/LS3wj1IhhsGDSOqfNmU6av2vgMwxJ/AxiN
k+4l687vCqwkfng2U+UjXdfchZGNGo7EamnlcFoW+KZPZZzEWXdFi9q9azIR0Ii6
qNk3qO0v08NV4pM8EebmOpL4HJxCEyfuEJecXW71lILSU8GIW8+oSKtgN2rRg1XK
961tCq1RMyVRZDrfLdRPE9BWzzuUOSt4GoOpdrHoMWkG0Pe9W+L4ThZC6yvpYbYA
6aSdN0LIYJd3pA0uR6z4eS39tZYQNq+Odx0KMDAlAVrWOSkeRjwQwyrCdNerjBI8
VudRLw9j4Hzi0iuiDIH0Sl5fRXUMZS57YHCRQwiNOoAB66YDtiBlT4skxLcYeAeH
iyReWixDWF3xoTIZNt5aB2QPLoDXbauzq5am/IDiFzETANdFIUDBe77C27UhafO4
jsWhBebtBE5VHmtmhIOIntUmMnCf2eA0YRN8flA8h+tN1UoUsZyHq1oTsgoNGHaj
gKaZ6mHMUkAvzkTtsZ+V
=FT3z
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
