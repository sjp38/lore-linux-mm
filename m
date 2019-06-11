Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC4E7C31E44
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:00:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CDA1206BA
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:00:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=dilger-ca.20150623.gappssmtp.com header.i=@dilger-ca.20150623.gappssmtp.com header.b="1PkfIHxo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CDA1206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=dilger.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4EBF6B0007; Tue, 11 Jun 2019 17:00:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFEC66B0008; Tue, 11 Jun 2019 17:00:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEDBF6B000A; Tue, 11 Jun 2019 17:00:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6516B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 17:00:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r142so9142059pfc.2
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 14:00:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:message-id:mime-version
         :subject:date:in-reply-to:cc:to:references;
        bh=nUPaXZb2EyHCiKOm64w17o/WMgOXwq3cvo71tUNaOwE=;
        b=gycQYSLJRVE1ANOsIqfXUrTRhZAFObopitT+FEslP6+2qf3yE8xZhtHIUd+fuUxGyM
         6qup5fLrgD0RfCG7diL8wffq94vDV7cqYBef+tlbOEFcO3Ad6ImKCJgfSiYZ6Cpj7194
         9SYikwZQt24LsnTT3Z4H/056j4Vl4KlnIYmucw7TOkXVrCp3VVOlzyqHjlvdSORbJj4R
         mT/5+wBujy7hnq/JAhlNKTWkLMOEG92auF+D9al4A4+w1UlLtFvobTTg2aE3YL3yumqp
         DXWr9wIu1j11Or65BZHF8Xns70hOlxBUBNKeflukaKTlX9MB4+dnA7dJv6tgS6FieKnD
         6k4g==
X-Gm-Message-State: APjAAAVgm1FBYTNzx0NrmZEvttVlI6qbZ64K85a8y3bm4Ia2cZOrrSGp
	Sm5RqH1rkSC9qBIAGdqUip+lsrN32uqK3sUdiXnDTTyhe43bxT7CGu9ATb0PW71/AKSEmmrF2Ca
	aaHfgpt/mzWxe+gqwZpXsg3LttgAy3ICzwWhaa+eBeybA3ORi5s58hGwezKigIf/DFQ==
X-Received: by 2002:a62:58c4:: with SMTP id m187mr24743538pfb.147.1560286817124;
        Tue, 11 Jun 2019 14:00:17 -0700 (PDT)
X-Received: by 2002:a62:58c4:: with SMTP id m187mr24743432pfb.147.1560286816174;
        Tue, 11 Jun 2019 14:00:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560286816; cv=none;
        d=google.com; s=arc-20160816;
        b=hzxbp482KbY2ajiQ/BbV12x89RBqC3M2Rc23jIgxn0B2pKOP8bPxuP0m1Nf55rfz+b
         hqPmZHG4XtaIcjVtO1O1oDScuYG7D9fB75iWy6D13njTrs2HnmIFjZthEaomTOY07WDf
         voh+FHB5NY4DhFWM2nDyjmXP/cnftQq8jEaNm86ipPrAmsQLf1zXtoXtIcq+dMbiquWj
         iNcLuSeTaWjBGSmcQyRTxsEAhY2Y9iDwesfFi6dSAjCJNHIiciN1Gt2vXtlaUX7L+K4U
         rs4otGLcpekkXNh1k3cq0st08V/x9g9n9ULbb9UxgSRSp+PRDLbxNA0h4gqRFzZ9NR4M
         5UUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
         :from:dkim-signature;
        bh=nUPaXZb2EyHCiKOm64w17o/WMgOXwq3cvo71tUNaOwE=;
        b=z+GNF5wWtLQN3JhXqEjDslFhNd8mx1ESIRE4c4g/xz9MUjV9+VeMYRjqVy64eKthxu
         3PkUdB5JVuhx3PlYDMiKBn/8y/7mew08Cff8hSaygr3welO4KpQ6NBL763j9Rcs2Kyfl
         Siz7nKv2VJmY4YLtMvOCdWOdCA0Mp3zGFLStH8pou8majl0/BXfMr0CGWDnYMHxT0vhP
         tDccxXpynt6RDgwVvb/1h44qyvKPHO/UwFU1CLdOkE43G7PKCqV4AsaCu1qbwsdwVAOz
         AMsPOYNUMTP/29RbHA55q3b9lKnN5/Znw9TJA9t1su1ZApxFVxExyTLzxpJds0mpc+J7
         kgiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@dilger-ca.20150623.gappssmtp.com header.s=20150623 header.b=1PkfIHxo;
       spf=pass (google.com: domain of adilger@dilger.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=adilger@dilger.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor12627338pgq.52.2019.06.11.14.00.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 14:00:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of adilger@dilger.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@dilger-ca.20150623.gappssmtp.com header.s=20150623 header.b=1PkfIHxo;
       spf=pass (google.com: domain of adilger@dilger.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=adilger@dilger.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dilger-ca.20150623.gappssmtp.com; s=20150623;
        h=from:message-id:mime-version:subject:date:in-reply-to:cc:to
         :references;
        bh=nUPaXZb2EyHCiKOm64w17o/WMgOXwq3cvo71tUNaOwE=;
        b=1PkfIHxoAL100GHTIJPtUgnC6vtovLyncp9xFBxlnggPu12+zsDGgnLaBjug3WcCRF
         ADQVr3JetSynDAQbtUt6ErvLUOeaCpig1636+Ma6Jq/Pzq9Wm8vruTUnsCFntkIJGXPX
         wWnf8ZOx9s4y5y8Qm3ZvQvL2os1TOwaLQLvbm9ZJou9U0nJzedf/8LPDMnNkHoMmIRvm
         0JVJjUBp99ct05cqa2egnpZd13j2INZwnsHocqWKQQe5RqyURZIMrPteLnuZG4T+3ubQ
         FsvDJpuZH3QIeO3XlnkM7vdfDShdyMdLnG6hcUpiZJVNutSS2SeLa5Fxo2XceNqs4ysr
         0rpg==
X-Google-Smtp-Source: APXvYqw4YBmB5zv3pmuSF2o1Ro24lhPZ3aL8+7Yz5YYkMM5A75U9mLeByV4nZS/X2MAaqVMFGY5qAQ==
X-Received: by 2002:a63:4419:: with SMTP id r25mr22692286pga.247.1560286815720;
        Tue, 11 Jun 2019 14:00:15 -0700 (PDT)
Received: from cabot.adilger.ext (S0106a84e3fe4b223.cg.shawcable.net. [70.77.216.213])
        by smtp.gmail.com with ESMTPSA id l1sm14357897pgj.67.2019.06.11.14.00.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 14:00:14 -0700 (PDT)
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <6DCAE4F8-3BEC-45F2-A733-F4D15850B7F3@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_31ECB8A0-2497-4644-8BE0-DFE1190172F7";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH V2] include: linux: Regularise the use of FIELD_SIZEOF
 macro
Date: Tue, 11 Jun 2019 15:00:10 -0600
In-Reply-To: <20190611134831.a60c11f4b691d14d04a87e29@linux-foundation.org>
Cc: Shyam Saini <shyam.saini@amarulasolutions.com>,
 kernel-hardening@lists.openwall.com,
 linux-kernel@vger.kernel.org,
 keescook@chromium.org,
 linux-arm-kernel@lists.infradead.org,
 linux-mips@vger.kernel.org,
 intel-gvt-dev@lists.freedesktop.org,
 intel-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org,
 netdev@vger.kernel.org,
 linux-ext4 <linux-ext4@vger.kernel.org>,
 devel@lists.orangefs.org,
 linux-mm@kvack.org,
 linux-sctp@vger.kernel.org,
 bpf@vger.kernel.org,
 kvm@vger.kernel.org,
 mayhs11saini@gmail.com,
 Alexey Dobriyan <adobriyan@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
References: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
 <20190611134831.a60c11f4b691d14d04a87e29@linux-foundation.org>
X-Mailer: Apple Mail (2.3273)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--Apple-Mail=_31ECB8A0-2497-4644-8BE0-DFE1190172F7
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 11, 2019, at 2:48 PM, Andrew Morton <akpm@linux-foundation.org> =
wrote:
>=20
> On Wed, 12 Jun 2019 01:08:36 +0530 Shyam Saini =
<shyam.saini@amarulasolutions.com> wrote:
>=20
>> Currently, there are 3 different macros, namely sizeof_field, =
SIZEOF_FIELD
>> and FIELD_SIZEOF which are used to calculate the size of a member of
>> structure, so to bring uniformity in entire kernel source tree lets =
use
>> FIELD_SIZEOF and replace all occurrences of other two macros with =
this.
>>=20
>> For this purpose, redefine FIELD_SIZEOF in include/linux/stddef.h and
>> tools/testing/selftests/bpf/bpf_util.h and remove its defination from
>> include/linux/kernel.h
>>=20
>> In favour of FIELD_SIZEOF, this patch also deprecates other two =
similar
>> macros sizeof_field and SIZEOF_FIELD.
>>=20
>> For code compatibility reason, retain sizeof_field macro as a wrapper =
macro
>> to FIELD_SIZEOF
>=20
> As Alexey has pointed out, C structs and unions don't have fields -
> they have members.  So this is an opportunity to switch everything to
> a new member_sizeof().
>=20
> What do people think of that and how does this impact the patch =
footprint?

I did a check, and FIELD_SIZEOF() is used about 350x, while =
sizeof_field()
is about 30x, and SIZEOF_FIELD() is only about 5x.

That said, I'm much more in favour of "sizeof_field()" or =
"sizeof_member()"
than FIELD_SIZEOF().  Not only does that better match "offsetof()", with
which it is closely related, but is also closer to the original =
"sizeof()".

Since this is a rather trivial change, it can be split into a number of
patches to get approval/landing via subsystem maintainers, and there is =
no
huge urgency to remove the original macros until the users are gone.  It
would make sense to remove SIZEOF_FIELD() and sizeof_field() quickly so
they don't gain more users, and the remaining FIELD_SIZEOF() users can =
be
whittled away as the patches come through the maintainer trees.

Cheers, Andreas






--Apple-Mail=_31ECB8A0-2497-4644-8BE0-DFE1190172F7
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAl0AFloACgkQcqXauRfM
H+AuLxAAgNkosRb8jCBUvSkSZcRIz6m3CRCKyZBz9EPhtA2ihZfEB+0hz1uGmXS5
opkX/nM8cIIrc2g/uiWBq6RVg8FFJxC3qVRDhPqDJ5b6jq6Q5WjV98HwBljIKIEM
EWXmiEtnxAQAWrNcYoI0HAI5nMUxpIHxo0+hWnfLhk/fTPoUwgLgZawDmn+pwcND
DU07/6GM67fcfUGYxZKD43X6a/s2lkR28Nn3MN7o2Y/exOm6J0otNWB4Vsu7d6t/
cScoBhni7d5c02FbLXTpab1n/Sjq/+Ijd3yp3ooxjoFvhfqx6YoBYL5fKxZx29HO
AXautmzcIwSccj17hB9lIvq/lLdXBL/k9qiKBcIzImCLxSa9+hMJFcl4gH3Qo4i7
J+7jzFHXnFnx9g5J4rka5VIlGpbBM85N35g8vJZFGVc/juJm6r6YXA+48kKI6hZB
uFH8fNhjYJGDFyiCh637pF5CObUattAasEPN8O8mQ3qxZKg8C/9jvOLgHlI9W9iK
ijBEDk0atDHpIJe3dlUw/fQA7LZ4bvXe07VUBqnBUd+/+7KBLZxLkfnygJXf8nzX
k0TILorUWagkDNgpBE/vwV1ER8UzU6NRxz/w4e6/N/mufG7iPcxZjCTtfJUS3GLW
hPKj3bi6qV6cw+EyroLHp9igONkqhvnPjEFx5a4YA3gAxQ8viSE=
=5D1y
-----END PGP SIGNATURE-----

--Apple-Mail=_31ECB8A0-2497-4644-8BE0-DFE1190172F7--

