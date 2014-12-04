Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id F3CCE6B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 02:30:49 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so17195634pdi.2
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 23:30:49 -0800 (PST)
Received: from ponies.io (mail.ponies.io. [173.255.217.209])
        by mx.google.com with ESMTP id fn2si41968523pab.9.2014.12.03.23.30.47
        for <linux-mm@kvack.org>;
        Wed, 03 Dec 2014 23:30:48 -0800 (PST)
Received: from cucumber.localdomain (58-6-54-190.dyn.iinet.net.au [58.6.54.190])
	by ponies.io (Postfix) with ESMTPSA id 327A7A0F4
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 07:30:47 +0000 (UTC)
Date: Thu, 4 Dec 2014 18:30:45 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141204073045.GA2960@cucumber.anchor.net.au>
References: <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
 <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
 <20141203075747.GB6276@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="6TrnltStXW4iwmi0"
Content-Disposition: inline
In-Reply-To: <20141203075747.GB6276@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 03, 2014 at 04:57:47PM +0900, Joonsoo Kim wrote:
> It'd be very helpful to get output of
> "trace_event=3Dcompaction:*,kmem:mm_page_alloc_extfrag" on the kernel
> with my tracepoint patches below.
>=20
> See following link. There is 3 patches.
>=20
> https://lkml.org/lkml/2014/12/3/71

I have just finished testing 3.18rc5 with both of the small patches mention=
ed
earlier in this thread and 2/3 of your event patches. The second patch
(https://lkml.org/lkml/2014/12/3/72) did not apply due to compaction_suitab=
le
being different (am I missing another patch you are basing this off?).

My compaction_suitable is:

	unsigned long compaction_suitable(struct zone *zone, int order)

Results without that second event patch are as follows:

Trace under heavy load but before any spiking system usage or significant
compaction spinning:

http://ponies.io/raw/compaction_events/before.gz

Trace during 100% cpu utilization, much of which was in system:

http://ponies.io/raw/compaction_events/during.gz

perf report at the time of during.gz:

http://ponies.io/raw/compaction_events/perf.png

Interested to see what you make of the limited information. I may be able to
try all of your patches some time next week against whatever they apply cle=
anly
to. If that is needed.

--6TrnltStXW4iwmi0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUgA2hAAoJEMHZnoZn5OShKA8P/1Wqa3sVoC7ixEICjzeFAyHF
d2fjZuPOYHSDs97D0QCz+f+ITS1KfFfVrJ8APjX06eDnDGpTAPVz1bacrh2uzHXs
x3sEVwTCjeit+wGHnR3g4mgsJzoUREEk+Wr0xlbY0OU6uvlNG5iTeyEwTF/dfCIU
XZiGao8K0DsJa6mMPWZIr6zsazMD+WAsI5JhRlGml+NT0ctoPAKT2OfmNzCdMxSO
KvMg9eVVtpAjniNQgP1hasGYG2A0mBQJtZ5/kP6QtHPuTnCvqjlo3whrE4KBkPtC
/CI2P2rH0hTcuo0Df5hc4b8qncUBcQheRkribavjmWL/fPLdwde2r0HXNoKaTY5e
1Ied78mQhvYM1AnVLJAP7fpIet2s0rlVXGK6abRo1RwTdogvXNMoIOzqxB+zrLgF
cuN6UrpphkQaC1zH00UJP3FBau6gVu0YwQK2jiKrm6QZQgUU9Ntj5C/ADCPRPIlK
IervopAEVrxrQ5a5/I3qd4rsAWZm8YrlvdGqtf+23oSKTCwgqAGIIb70U38flXmN
SWCntVDhhdSk+/Wrf0YyC1c9uUEUX01QmhA7lsC71Umu6delEQhERwE8RTRcDpVo
UcjmVGbjTOQUUUGF+LXAB8rTSmTjwdTCA+yaD388vKf52A5DWGQpP/3cV/Owzkh/
a0e1H32C3ufWMNVnDEdE
=i6H2
-----END PGP SIGNATURE-----

--6TrnltStXW4iwmi0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
