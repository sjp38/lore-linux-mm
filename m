Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2092C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8A59206E0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:37:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8A59206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ucw.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58D8C6B0005; Wed, 12 Jun 2019 07:37:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53DD66B0007; Wed, 12 Jun 2019 07:37:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42D896B0008; Wed, 12 Jun 2019 07:37:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA8156B0005
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:37:17 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id f189so1097373wme.5
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:37:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7bkmJXhFF47r5AyND7v53Qh3+Zc2WTWvJCcGjnl+w1c=;
        b=g2GdQuxtgbGKHeVcoJUH0F+opK6ukl2dtmPNAq3iD/klBfwnoYWd00fyhYtamqTFgp
         ZjasSs1SmdINpKlf8lAECC4skGZfvEPg/3IufWXQ1h9H2eB/sw+cQE6DjW3xr3359bYd
         r0u11dAUYlA3augHkr9IFY9gXmlCkItlVADnqS8QdFC2Y+BvS05FgEn27dQUmlnGTV9R
         HbdIlpX+UZqHAEL27qrJgRbxwT703KimhQEFET1Vk0cwSnUZaEHPVp9f11umXVexj/UU
         bpvEuFTG9dKXbzqV2ISIG5j+xhSF53dkRpFoBJouse92PmkwV0i9/DMipG7JXlr+HutT
         bzGg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
X-Gm-Message-State: APjAAAWv2yFavoOVVDzn9WPzR2uD0P7cMy+SmCVN/PC/PJ69dGMggWxc
	K3LoA6tItEpgx5zAohUx/HU64lSgkSb7qotk2Tqx06tqQndmIW4HjzgwAi7CHYSAClH78leQ4jV
	baJ1nm4nAcOdULz/bDzzvU6O73p+Q5UbpE5lIgFSTPSzDO1ncG1+keyQdwJkrsn8=
X-Received: by 2002:adf:82e2:: with SMTP id 89mr1666185wrc.33.1560339437440;
        Wed, 12 Jun 2019 04:37:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjshSOUs63OawiPa1SLdtbOMS3GMZBf8rqq5hsV3w2yywwfhpMnSzCjPGYX0h33GU6uUty
X-Received: by 2002:adf:82e2:: with SMTP id 89mr1666129wrc.33.1560339436556;
        Wed, 12 Jun 2019 04:37:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339436; cv=none;
        d=google.com; s=arc-20160816;
        b=wZWOf6vL0ppFGURQ+3JYjqoT5wcsNFQy6EjGRwQsIAiz/oK0+0+hk/nQdR0tgbuFBc
         hS774mwjDnV6RS3hhV/FE3v7CPxdjKNsNmF/cyxtcfdL+nJzbfgWn8kscNybptmqkidx
         RhtrOubscqiIam9eW3AGGWv5Puc8lJoXeNfoRneLo7R7NjKP+zbaVxz/xJYqVP2fLuja
         DNUiUh24jOjRFxD9ilUNWJRKNtZA7xBDgrpfvK8ZobosftcJVFwxo0U5lrzDvJQmrF9o
         rJUPAdQ4ow8zpIjazhTI9VF3JQrSyTCIt6UMnxsWbGx8GT3yW8piOHkzbAh1JCohhqMj
         WhYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7bkmJXhFF47r5AyND7v53Qh3+Zc2WTWvJCcGjnl+w1c=;
        b=M4hxwfvzUyWpg4DDAqmu1XvHR1jc4TlB7CBPNujlYAG4SuQU9mv5qGkcSyLtAwfR+S
         KHJjWVDw2ClS4G5f4MGRHqgQXsvLx0nghYLxTr/w5t1vJjI6ZjH3qbXVTYMmkPHZLRZU
         95l1CXn6WvZrCzT7Q+gmsU4AYK2wLB8iMFPWgmorP56yGoUd962eWcsoT8F0toTRDJ1/
         tXrG3vg8ufJOlf5bpwZS8qhXzmGs+BNXBUKZ6IS5l7lEihIhhwqTj+X1CVrTgXDQdnvH
         X0WaYDJvoO4SVXXcZels/pd/O8+jaVlbj6I1LJh9UPEN9Nbka2UQlW4jkEYlu1v1dqY3
         QQyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id p17si14120647wrw.42.2019.06.12.04.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 04:37:16 -0700 (PDT)
Received-SPF: neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) client-ip=195.113.26.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: by atrey.karlin.mff.cuni.cz (Postfix, from userid 512)
	id 7C0EA802EA; Wed, 12 Jun 2019 13:37:05 +0200 (CEST)
Date: Wed, 12 Jun 2019 13:37:15 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, hdanton@sina.com,
	lizeb@google.com
Subject: Re: [PATCH v2 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190612113715.GA21366@amd>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190612105945.GA16442@amd>
 <20190612111920.evedpmre63ivnxkz@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Content-Disposition: inline
In-Reply-To: <20190612111920.evedpmre63ivnxkz@butterfly.localdomain>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > > This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> > > information required to make the reclaim decision is not known to the=
 app.
> > > Instead, it is known to a centralized userspace daemon, and that daem=
on
> > > must be able to initiate reclaim on its own without any app involveme=
nt.
> > > To solve the concern, this patch introduces new syscall -
> > >=20
> > >     struct pr_madvise_param {
> > >             int size;               /* the size of this structure */
> > >             int cookie;             /* reserved to support atomicity =
*/
> > >             int nr_elem;            /* count of below arrary fields */
> > >             int __user *hints;      /* hints for each range */
> > >             /* to store result of each operation */
> > >             const struct iovec __user *results;
> > >             /* input address ranges */
> > >             const struct iovec __user *ranges;
> > >     };
> > >    =20
> > >     int process_madvise(int pidfd, struct pr_madvise_param *u_param,
> > >                             unsigned long flags);
> >=20
> > That's quite a complex interface.
> >=20
> > Could we simply have feel_free_to_swap_out(int pid) syscall? :-).
>=20
> I wonder for how long we'll go on with adding new syscalls each time we n=
eed
> some amendment to existing interfaces. Yes, clone6(), I'm looking at
> you :(.
>=20
> In case of process_madvise() keep in mind it will be focused not only on
> MADV_COLD, but also, potentially, on other MADV_ flags as well. I can
> hardly imagine we'll add one syscall per each flag.

Use case described above talked about whole-process-at-a-time usage,
so I'm asking if simpler interface/code is enough. If there's
motivation for more complex version, it should be described here...

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAl0A4+sACgkQMOfwapXb+vL5YQCghuEijV5YAvkI5fTH2VOxFvri
GLwAoJHEuclcX7PmhKr8Ht0OQ4+EHl8w
=CpBo
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--

