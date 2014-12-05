Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A69C76B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 00:50:52 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so35535pad.1
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 21:50:52 -0800 (PST)
Received: from ponies.io (ponies.io. [2600:3c01::f03c:91ff:fe6e:5e45])
        by mx.google.com with ESMTP id us1si22760562pac.23.2014.12.04.21.50.50
        for <linux-mm@kvack.org>;
        Thu, 04 Dec 2014 21:50:50 -0800 (PST)
Received: from cucumber.localdomain (nat-gw2.syd4.anchor.net.au [110.173.144.2])
	by ponies.io (Postfix) with ESMTPSA id DB58FA0F5
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 05:50:49 +0000 (UTC)
Date: Fri, 5 Dec 2014 16:50:47 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141205055047.GA18326@cucumber.syd4.anchor.net.au>
References: <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
 <20141203040404.GA16499@cucumber.bridge.anchor.net.au>
 <5480EE9D.1050503@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="5vNYLRcllDrimb99"
Content-Disposition: inline
In-Reply-To: <5480EE9D.1050503@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Dec 05, 2014 at 12:30:37AM +0100, Vlastimil Babka wrote:
> Oh, I would think that if you can't allocate single pages, then there's
> little wonder that compaction also spends all its time looking for single
> free pages. Did that happen just now for the single page allocations,
> or was it always the case?

This has always been the case with the default min_free_pages and given enough
pressure for enough time. I have just been hoping that compaction should
be "smart" enough to lest reclaim do its stuff quickly if single page
allocations are failing.

Raising min_free_kbytes makes these 0 order allocations failures never happen.

--5vNYLRcllDrimb99
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUgUe1AAoJEMHZnoZn5OShwUkP/jZ7LRxWkGW+jsEVUCacvTZi
RH/mskEZ30MUtlsjFH7OKsfiXAKLFvMpRrVn8DVQvXNBmtp8KhjgTgj6iksN6m+N
fkbCKmz2VPaN0lVY+dm5QZR59fCqO/1qPuu6xi0BZIBjQqK79avI1riQZvGqHAsi
vwHDTTQ09QdlXYyiXhkKpJRNAhy3UkhprDSVUB6lbl+0q2brNvywCWng00+Ner6I
DiW+1ylJ951MT2uXyeUI8Az24NH1ykdjz5H90UZVvY/ptu7L81NHHOmHnOp49h2K
14Mzj0G5h9jpQn8Kic3bB+860IduaDsWwLNcf8EaaiUmaajeMj/rm4uv0lnVm0dH
37bl6XF5HYZhwPFekJLck3tXUzivmwVgm34TIUh7SyrpaomnY4Cgl8cSyWZzRzPN
EtunuaF7K+T049mp9k3YrPmLQDdTjsJtSGl3c3M5B37PWB4V74IdlvdhNR0d13qw
JhlHVVR1HtMVuT6c/pKh5Sqp13t3sdZoWwQQzzZvdnhFEUyTTKr9dahaEHWDdyNw
y+E9bAIKBQ/RC29MAFpN4K6gM3j+P5+40mFAowVgrAKMuddIze7xNQrBRHoNpXOf
bnpcUWtBcAuj4nq/AWPBXlwLZ7CDOBSRJn95N82z3txXP0MkzaOARBAhBHst7qj8
7j6/m4/DkZ4vO5WDB+5B
=Ehnd
-----END PGP SIGNATURE-----

--5vNYLRcllDrimb99--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
