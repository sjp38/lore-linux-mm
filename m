Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 155A9C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 10:56:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D235021734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 10:56:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D235021734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5335D6B0272; Tue, 30 Apr 2019 06:56:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E3156B0274; Tue, 30 Apr 2019 06:56:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AAD26B0275; Tue, 30 Apr 2019 06:56:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E12AA6B0272
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:56:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b22so5170777edw.0
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 03:56:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oRfcno0+NNETk5R1+SELVe6SDYQYFpKkPSkjR9fOkWY=;
        b=CV0mlRsbhePLngii2C5uNsrV9T54GQkK9qPH0yI4cET9IsTdvuf0B1ZvwBQv1zIT2/
         Pum6IpLWCepoOE6T3QZ9MKBU9fFykYe19SPHPTfpsngyofY8RaqOZfxoddB9nZUUbad8
         dl9vFafKbUU1/s7K+IDwbok4HNIJXL40kxAF885WobjeuMpdt0UaIzL072cSm8JlW4gQ
         h58aICBkmEmg1/72YMm+Rw/a7CMLGgvn8hoSDclzqHh76i6poxIpmrhL03Z3Uq6RYkcU
         HjenOkezGINLZ4VjmGBi97zOkl84qB/i0Xy4MTgB4fRd0kSYudmv8W5lP0bQAgKm5QPD
         EiUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAXrEof1A+IdDU9LPCO+IEDWjhfpTV2oeGybZEyTFlD2VBLbIRLz
	ia6GahcRjE4I/RPwqJ2JPDhauP2PmP0w+1Tc7fQnwyT6TbtIMrkLH5SMVF7iU1m+SNDAn3WKFRM
	UYHdZRPpOfT9VFw2DhGmtk0+sKFoHbYuVxbEv7w468Oc8XjqRkRhcPiq200+ULSSJrQ==
X-Received: by 2002:a17:906:66c2:: with SMTP id k2mr33611548ejp.181.1556621775480;
        Tue, 30 Apr 2019 03:56:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOtLfrZ7aaeOnMTUW9jq6ylIKZMbzHgHB8hych/8ekcv/9ERnhBh0VzCnhH8O2QiBJCTht
X-Received: by 2002:a17:906:66c2:: with SMTP id k2mr33611516ejp.181.1556621774670;
        Tue, 30 Apr 2019 03:56:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556621774; cv=none;
        d=google.com; s=arc-20160816;
        b=MwcGmXTNEIiO2vjeXy5tNzmWA8Le9y71thJfmfl/2/IkDruca5KvWI2D7DuDw6IFMA
         uiCKrretq7QPeYLaVl5q08rhjvzpJ9QtctB5FgG7ge+Os+uy/VwxNmVHzhHl+kJ364Qf
         KUDsyPILRQcQ9Z2IPq0dTns/a+7dSkt9TWLOtU9GrDw9/KmmUbgug0Q6hhG67gSX0BKO
         sh6UQ6Cae7sAgDvr/+HUeyyFkX5FiOWROg7wmDgRyelU2Bj+q/t62hoPXYsssldnzifo
         7z8hpAlWCloGIWOKXJoBlcewkhnRXvC2MSvXNrBdNx24KJesgfitoCWy+sPjLvDvRxjV
         zzmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oRfcno0+NNETk5R1+SELVe6SDYQYFpKkPSkjR9fOkWY=;
        b=TLZeJfzq9I53Nm4dXDYUHOhamMvGy4cWsKUTDm5QF+iEFWfoSN5JMHa0YIiRylLli2
         J565yyukRTOS9RovVZhgh/qI/eBonUgSnMqxRiI1OIB6PuIQctpbe9XLjciEWIyPpuUa
         7GPpPaPJi0KjojDOUY9OPv98xBGYO7o9s+Xc6QZx6d50KAZk9KSpkf9a+Z6qEjxaKQso
         Nu1XJv81Hm37JFScYHq1EVO+w5MJxMyrdgykjI0hU1sABv5+KS1dNm/XjoEUpdwCVe08
         jdV4EPeGnwid3ooK3SCp7uCOWBLCAHz7SIxcLkRmX31qDN7SUMy2cE9GQZZkRjaAaV9I
         tGOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si558461ejx.152.2019.04.30.03.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 03:56:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F2264AD12;
	Tue, 30 Apr 2019 10:56:13 +0000 (UTC)
Date: Tue, 30 Apr 2019 12:56:10 +0200
From: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, brgl@bgdev.pl,
	arunks@codeaurora.org, geert+renesas@glider.be, mhocko@kernel.org,
	linux-mm@kvack.org, akpm@linux-foundation.org,
	ldufour@linux.ibm.com, rppt@linux.ibm.com, mguzik@redhat.com,
	mkoutny@suse.cz, vbabka@suse.cz, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/3] mm: get_cmdline use arg_lock instead of mmap_sem
Message-ID: <20190430105609.GA23779@blackbody.suse.cz>
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-2-mkoutny@suse.com>
 <4c79fb09-c310-4426-68f7-8b268100359a@virtuozzo.com>
 <20190430093808.GD2673@uranus.lan>
 <1a7265fa-610b-1f2a-e55f-b3a307a39bf2@virtuozzo.com>
 <20190430104517.GF2673@uranus.lan>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="GvXjxJ+pjyke8COw"
Content-Disposition: inline
In-Reply-To: <20190430104517.GF2673@uranus.lan>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 30, 2019 at 01:45:17PM +0300, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> It setups these parameters unconditionally. I need to revisit
> this moment. Technically (if only I'm not missing something
> obvious) we might have a race here with prctl setting up new
> params, but this should be harmless since most of them (except
> stack setup) are purely informative data.
FTR, when I reviewed that usage, I noticed it was missing the
synchronization. My understanding was that the mm_struct isn't yet
shared at this moment. I can see some of the operations take place after
flush_old_exec (where current->mm = mm_struct), so potentially it is
shared since then. OTOH, I guess there aren't concurrent parties that
could access the field at this stage of exec.

My 2 cents,
Michal

--GvXjxJ+pjyke8COw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEE+amhwRV4jZeXdUhoK2l36XSZ9y4FAlzIKcMACgkQK2l36XSZ
9y43Zw//ShZK7DYk6l3lLVR4pXSaBs8MdnbIYo7kKlPHwKewLyueV6qPL2+k7sD9
M0bduFp4pZsGf/v2IG/1k6qStCpTYRFhLwiq9fiNee3j7pUhmxLTbTB6bIHtcU3p
96TrUAJK0J9Ll3vPRHvi3t6pGARq3M/3I7mVs/oWFGYT8wWy5yKoP1B+BHHbKcky
4xx3EaFJlwDeBZA8FgxxyrfbMvzLFJ1PgdSuaifuG8VH0wKYZhhzRtVB0U6o2DYF
MPce7LipyB4FG8NPWk0rWcrS/EjWDLV6zqRaOqYHKBryTYrLo2kyxp42QcbBSHsN
vSOimjkHLc6wnGE2798Pfsmy53aNucWE1s+vfuoqaGd4hXflp8hYU9MuM8MrV52C
OHkjozbWRkW0y6E0UGQ3H//7lYU2CTXOatHB0wRn3XeVhDynWaOXwZdcbG4WuzmM
wM04m8KsDFkLoY/uxSOeDKPPJUdwx/CGfzMvI7or47ic/BkN7GOtbsz4ktNiDg66
c6hgOEp8jUi+PPsAcEfzIRX7NKpWhpi5MLLTqfY3KGg6UnszjSOb1us4/XTr1Ok+
WRhUZy+lkVI6/sLy6JlDyCDPQGkM96ZmJC/yRsUqvQeiaUhG99DiU5tL2IZqmbN3
XQSp5NcX0a7or597DEf0zJXfqO0vkHugAenNGardDU17d0iJH9w=
=qs9v
-----END PGP SIGNATURE-----

--GvXjxJ+pjyke8COw--

