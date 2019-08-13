Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A182C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:48:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B64B020679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:48:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B64B020679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ACULAB.COM
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B54B6B0005; Tue, 13 Aug 2019 05:48:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 365956B0006; Tue, 13 Aug 2019 05:48:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27B5F6B0007; Tue, 13 Aug 2019 05:48:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0191.hostedemail.com [216.40.44.191])
	by kanga.kvack.org (Postfix) with ESMTP id 06F696B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:48:07 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6CC1F181AC9B4
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:48:07 +0000 (UTC)
X-FDA: 75816928614.15.north60_63f2598af6c36
X-HE-Tag: north60_63f2598af6c36
X-Filterd-Recvd-Size: 3299
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com [207.82.80.151])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:48:06 +0000 (UTC)
Received: from AcuMS.aculab.com (156.67.243.126 [156.67.243.126]) (Using
 TLS) by relay.mimecast.com with ESMTP id
 uk-mta-150-kKZsyMR6MtydRYGBEb95CQ-1; Tue, 13 Aug 2019 10:48:02 +0100
Received: from AcuMS.Aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) by
 AcuMS.aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) with Microsoft SMTP
 Server (TLS) id 15.0.1347.2; Tue, 13 Aug 2019 10:48:01 +0100
Received: from AcuMS.Aculab.com ([fe80::43c:695e:880f:8750]) by
 AcuMS.aculab.com ([fe80::43c:695e:880f:8750%12]) with mapi id 15.00.1347.000;
 Tue, 13 Aug 2019 10:48:01 +0100
From: David Laight <David.Laight@ACULAB.COM>
To: 'Joe Perches' <joe@perches.com>, Nathan Chancellor
	<natechancellor@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>
CC: Nathan Huckleberry <nhuck@google.com>, Masahiro Yamada
	<yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>,
	Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, LKML
	<linux-kernel@vger.kernel.org>, Linux Memory Management List
	<linux-mm@kvack.org>, clang-built-linux <clang-built-linux@googlegroups.com>,
	"Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: RE: [PATCH v2] kbuild: Change fallthrough comments to attributes
Thread-Topic: [PATCH v2] kbuild: Change fallthrough comments to attributes
Thread-Index: AQHVUaVgEyLklNacm0CAPm1TaF5b6ab40/BA
Date: Tue, 13 Aug 2019 09:48:01 +0000
Message-ID: <85e25647ae404bf38bc008ea914e08b3@AcuMS.aculab.com>
References: <20190812214711.83710-1-nhuck@google.com>
         <20190812221416.139678-1-nhuck@google.com>
         <814c1b19141022946d3e0f7e24d69658d7a512e4.camel@perches.com>
         <CAKwvOdnpXqoQDmHVRCh0qX=Yh-8UpEWJ0C3S=syn1KN8rB3OGQ@mail.gmail.com>
         <20190813063327.GA46858@archlinux-threadripper>
 <3078e553a777976655f72718d088791363544caa.camel@perches.com>
In-Reply-To: <3078e553a777976655f72718d088791363544caa.camel@perches.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.202.205.107]
MIME-Version: 1.0
X-MC-Unique: kKZsyMR6MtydRYGBEb95CQ-1
X-Mimecast-Spam-Score: 0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Joe Perches
> Sent: 13 August 2019 08:05
...
> The afs ones seem to be because the last comment in the block
> is not the fallthrough, but a description of the next case;
>=20
> e.g.: from fs/afs/fsclient.c:
>=20
> =09=09/* extract the volume name */
> =09case 3:
> =09=09_debug("extract volname");

I'd change those to:
=09case 3:  /* extract the volume name */

Then the /* fall through */ would be fine.

The /* FALLTHROUGH */ comment has been valid C syntax (for lint)
for over 40 years.
IMHO since C compilers are now doing all the checks that lint used
to do, it should be using the same syntax.
Both the [[]] and attribute forms look horrid.

=09David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1=
PT, UK
Registration No: 1397386 (Wales)


