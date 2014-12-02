Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0E46B006C
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 00:06:13 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so12433817pdi.30
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 21:06:13 -0800 (PST)
Received: from ponies.io (ponies.io. [2600:3c01::f03c:91ff:fe6e:5e45])
        by mx.google.com with ESMTP id yt4si31945425pbb.62.2014.12.01.21.06.10
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 21:06:10 -0800 (PST)
Received: from cucumber.localdomain (nat-gw2.syd4.anchor.net.au [110.173.144.2])
	by ponies.io (Postfix) with ESMTPSA id 19281A0EF
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 05:06:10 +0000 (UTC)
Date: Tue, 2 Dec 2014 16:06:08 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
References: <20141119212013.GA18318@cucumber.anchor.net.au>
 <546D2366.1050506@suse.cz>
 <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
 <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="X1bOJ3K7DJ5YkBrT"
Content-Disposition: inline
In-Reply-To: <20141202045324.GC6268@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 02, 2014 at 01:53:24PM +0900, Joonsoo Kim wrote:
> This is just my assumption, so if possible, please check it with
> compaction tracepoint. If it is, we can make a solution for this
> problem.

Which event/function would you like me to trace specifically?

> Anyway, could you test one more time without second patch?
> IMO, first patch is reasonable to backport, because it fixes a real bug.
> But, I'm not sure if second patch is needed to backport or not.
> One more testing will help us to understand the effect of patch.

I will attempt to do this tomorrow and should have results in around 24 hours.

--X1bOJ3K7DJ5YkBrT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUfUi+AAoJEMHZnoZn5OShhTAP/2OmwsMoAqzd1zPh3ffjdBIm
TmDOfHbWZ/lDgQTtteslf3VZFZnhVABb2b01uOyC30FmbzqcZz/mj2zgdKep++LM
QFrrlPN+MxSDsfA5X1dCcj7oN7EUgAAas6xeHqcbFGs1PKJOQkxo/BEYhbUieYfi
VJ6hdfs9jjWZySe9RaiUmXX5QdW/IBbZES+bgAUxBc4YWKq/WNT3BXSlzV7tga+d
rG6IU2aoCaztjcIGm0Ny89Ig23S32UKbpcSFQF9Nrg3IX3CbEBQyj37HQN4BW1Qa
5NGmKkAmZ2WIokmB/NC21Qpz/0DXYNGWUMMA/rcprY6UNB1nRKXiLtQ4amD1HqSV
WpzoBIUXNSh7RmVgMTznqvOI94WGak9lfgXafz9fX2dPXbgQ9vd8jdSj67FCdioC
cKPJkbGqf+IAjAQsUDPSWCs0chj+ktvfTJhLPGAZp8tppjkPnJeWBGw+t+e04qWr
lYLMKUS9Mzmj1shJPpZLWecX0QeSOFRVpT+8Rhy4HlXLx/hnsKMNvRr9ZAx/3XpH
VncScAXKj4Le+d0tXo1vGC9QrcxNApWghMj1UVE5SupUoNcuNnl/c9UiNXJe4YK7
kXQ2EdGBOb4U7twHaxjSk8pwjQKblHDnAJOd5Qa3QWXzscCNRccEK/ws0UchoUar
7QANSb7saRAEYNNGylSF
=YupH
-----END PGP SIGNATURE-----

--X1bOJ3K7DJ5YkBrT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
