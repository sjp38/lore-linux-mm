Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8972C10F13
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 07:59:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D8FF218FC
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 07:59:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D8FF218FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ucw.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C363D6B0003; Sun, 14 Apr 2019 03:59:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE3656B0005; Sun, 14 Apr 2019 03:59:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFB1E6B0006; Sun, 14 Apr 2019 03:59:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6575D6B0003
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 03:59:14 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id h13so11676597wmb.6
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 00:59:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=He4CKD94c0rbePt7pfPFqsUT3jQqH/DPsNm4gYTehP8=;
        b=FgGz8pJlLwzQK/n9YEsgmqlPPHBJk9uazU+1HaD/3cclW8TUMeHxXyQYp458rKJb3E
         ZhTtKrL9lZ0bBlYKcFAG7B9BMk8e2NNbcYSYOrtUq08hFCXNXATnf+lJ5OrXubRAaVUA
         LLgVRhMJpeXpGRJifXQM+aheO+ZqKQNCyFGxmBS5HRJ2qy6Na5J+XSto+x9DAiWjdkcp
         DHxzRec9NrFCglGek7agoKa+nYPhXnJPKL4EgsSNFkNeHucr0PpsrPyheJyt4s193Jpc
         fDaExjOjQJgB+l3qu6n0JNKU9san0d0VL59PmEPWMzebKgoI+nTmkNLnDyrOpOdcVR1A
         HPkg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
X-Gm-Message-State: APjAAAXiGOs9Tc8kmDokAG7wJFLWoxvhsE+4Kyw9YV5HKTunITzFWzVN
	KaDTO5ifasdQjyc0aOoabnzOvQWQNsE08z0ABVOXqZaLW9nOiriVp/+LjHOaqyVN5c/dGmVDq4R
	GNkNyA0XNhNeQPmAeZI+vd6nT8tt0LVH36Irf/SDWUg9urtZxV73to4F12i9Kr8c=
X-Received: by 2002:a1c:7611:: with SMTP id r17mr5456331wmc.98.1555228753802;
        Sun, 14 Apr 2019 00:59:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdiPKlbkTnlfFVT12ocb46J+tkbO1nplldL7V38PhUbCPBJoG7czpknbG+R1tfNzDJ44wv
X-Received: by 2002:a1c:7611:: with SMTP id r17mr5456299wmc.98.1555228752898;
        Sun, 14 Apr 2019 00:59:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555228752; cv=none;
        d=google.com; s=arc-20160816;
        b=lJSfHy1rub6bqdS3st9aH7xRIXrgkxNNVALEZ8GJ+WyEJa/Xl8+YxXd9a6POE3uizI
         dTUMBg6KO/wZhUsCbalZ+DK0H+kKFU11pCEhybmxVOqDMAI+SazvvP0SZcFcRCc8hvd2
         LxFqoC22X/ztyjMxt8WT8dr04G0SuCl4lRuv2D0ez1xusi5VhSIs/bDSYTvWjbdnpcVi
         0Ft3p05X7zCNiOTqp3+6rJFDm5cU50rK05Xpyhn3YJaaAEFa4dbCR2qE6XLGKiV17jry
         a+W03Zpw9gembQFqgWZKMN7jV5yxfqAX1uB/ZnJDxXRsE3kLm22lq3TYCq4kJH0OABVD
         iRUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=He4CKD94c0rbePt7pfPFqsUT3jQqH/DPsNm4gYTehP8=;
        b=mrldA/QfABMXAuGjYY82/PYbYMP30fBzwUDfs5qpWa9isZeAeYBZZv+TUZ6itfzT1b
         B02qux8pBLjjumIOBCUF+ujdyvkuDjUwjng2EqKz0vmdZQgsg9yzKd3Cdi00HFI+ms9f
         P5cMlAN/QCqfqtYsdB4iAwnNsjQI7V4Tyk/vgkgH/TV/VV4YHuxOueAXOSb0WW8O3gje
         Wza+AFtQScpG47KGDSsbmeDm6ktDaUY7NX5oZRs+jx1lY0h7SQEsKhNheguRfvObu1v+
         DgSVeijxNtbJQhx3ecAVQYQW7F7Wu+/GzLY3Z5HZFeVhFEnHS5p/dWYqA+FAnTJ9EeW+
         vZCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id h206si8619955wme.50.2019.04.14.00.59.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 00:59:12 -0700 (PDT)
Received-SPF: neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) client-ip=195.113.26.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: by atrey.karlin.mff.cuni.cz (Postfix, from userid 512)
	id 9912280721; Sun, 14 Apr 2019 09:59:03 +0200 (CEST)
Date: Sun, 14 Apr 2019 09:59:15 +0200
From: Pavel Machek <pavel@ucw.cz>
To: syzbot <syzbot+9880e421ec82313d6527@syzkaller.appspotmail.com>
Cc: amitoj1606@gmail.com, ap420073@gmail.com, avagin@gmail.com,
	dbueso@suse.de, ebiederm@xmission.com, jacek.anaszewski@gmail.com,
	linux-kernel@vger.kernel.org, linux-leds@vger.kernel.org,
	linux-mm@kvack.org, oleg@redhat.com, prsood@codeaurora.org,
	rpurdie@rpsys.net, syzkaller-bugs@googlegroups.com, tj@kernel.org
Subject: Re: INFO: task hung in do_exit
Message-ID: <20190414075915.GA29199@amd>
References: <000000000000e02bf505866414ae@google.com>
 <00000000000074e9d5058674a94f@google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline
In-Reply-To: <00000000000074e9d5058674a94f@google.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat 2019-04-13 19:55:00, syzbot wrote:
> syzbot has bisected this bug to:
>=20
> commit 430e48ecf31f4f897047f22e02abdfa75730cad8
> Author: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> Date:   Thu Aug 10 16:28:09 2017 +0000
>=20
>     leds: lm3533: constify attribute_group structure
>=20
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=3D15f4cee320=
0000
> start commit:   8ee15f32 Merge tag 'dma-mapping-5.1-1' of git://git.infra=
d..
> git tree:       upstream
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=3D17f4cee320=
0000

Is there human around? Please take your bot on the leash, this is
obviously bogus.
=20
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlyy6FMACgkQMOfwapXb+vKFOwCfRgWU/WYanrFj17ZPDxKfLlwx
h+YAn3ywd9WkPk9NCik/4tydk6tI98bO
=aFTb
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--

