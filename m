Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D105C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:10:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D0B12067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:10:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D0B12067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA2278E0003; Mon, 29 Jul 2019 12:10:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A79478E0002; Mon, 29 Jul 2019 12:10:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98EF18E0003; Mon, 29 Jul 2019 12:10:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1F28E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 12:10:16 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id c21so6381059uao.21
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 09:10:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=KS/Q0AKesWNsot0Z7y/PMiQO19uhFoi/v0EaCSnNbCg=;
        b=CzG2JIBRIgkt04J9H9BuHwrUjo+wAiIKa0zamaD+9FZjFoXV2SorWLEnmzmUU75uvt
         PJtNFvlUKwXrgtdlgLVo+oTXcwAFor2HIMfAsa2chvAmDZqHTEHgSsYBi9yD921beTCG
         zMgtTpqGr47ZocR0ApTu49Rx1LO1ClTez6Wo6HNdCZyc5Klkh9RWVm5wmIJgKWSvqvf+
         XVn0vLk9DeNEYANUDAkokGBvDUjic1LSWr/XZuBH+oFb1iRnEtogDnCg1HO7EkWRbguV
         lxAZWUfxTTUGpOpB9/IfLm7EtiOrmELl8rY2qS9VJEHQbflL3FQzKGYmoxjYrlIv6xOI
         UrFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAX7OzFepdaslL/Vd7PN4j7aN7c7qJdk7cckBPjL5sjsF0jjDn44
	nfedva1r5Sds3esZw1xTeLlmyUXabYDvjjt7yanHudH76GRE+qTR+SgMp61XSAaBW5c8UBJQNdv
	8tNp51glL2w65VN/khtMbMubZAnQ7yMejHZJZSHDzF5wZFgYHrj14BNyafrCIDq3NoQ==
X-Received: by 2002:ab0:3159:: with SMTP id e25mr18690114uam.81.1564416616232;
        Mon, 29 Jul 2019 09:10:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsSo208ur/t8OfaVqeots62ayvnu1NQopcLufZz0B/ihqxTBmAQbSCki9oy+xwrQkooKKW
X-Received: by 2002:ab0:3159:: with SMTP id e25mr18690029uam.81.1564416615353;
        Mon, 29 Jul 2019 09:10:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564416615; cv=none;
        d=google.com; s=arc-20160816;
        b=fCTYaRBte6phGld30dgIbmnBo3Q0MvHcLr7Dvh+PYmfdonfLz6lNs0wj8KcfYjLpiQ
         RnUH5Is9tmHBK1sD6QOdWTHKV1EwxtjHrVx1+lkMXTAYoVXRDBT7Wip2LrdhiIqkKWW9
         2VrNNasx9kCa46357SEfa579edKYR/QXFRIOyolZneqbB0vEb76qoEr/XrYhAzSYs9if
         KDCwnv5M5woRY8yQd2IlJB3PWhEhAQ9dzsk4Yg3lVzX4cec8o1lVS8whhiFUCWYT1fug
         R4QYPepTDF6Syf0b9Ds1pBbOACS7TMDnyFoiJcJzyKRgBO0QKRkhzgB4FD0YwbFIU1eh
         4vAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=KS/Q0AKesWNsot0Z7y/PMiQO19uhFoi/v0EaCSnNbCg=;
        b=mUvu2ZjDSQ4dkXPnmO/1/TzebuJll6VGQ7sMYDdLpXib4BW2nuICLcrsVO9JEZmWOO
         LsmdZys00jDxdCN/2i2uE0EchXYCp5Lo2vJscXF1GzGVZymojmCjCvGj3CMtLG1OK7ob
         gUSQyKQh/cN41sBjzl3qZhdnK5pfFDECqXuOEdkBputEg3sAAqw7TUH6fwurGD3U9zRR
         g9WKtAnAVcyA9gb9BuJkRQTWNetmf1/hlNm1Z9HymoBeJBRt5LPpmgrtclaqB5rM6uao
         5yoLg2zY0c/DsIM+r15RHuhsdnchwmEzDu+N56LyUfdxlLZZigMOTOV+No06l4PEysqH
         bhpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id 2si4222140uao.165.2019.07.29.09.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 09:10:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hs8E0-0006Sx-QS; Mon, 29 Jul 2019 12:10:12 -0400
Message-ID: <aba144fbb176666a479420eb75e5d2032a893c83.camel@surriel.com>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
From: Rik van Riel <riel@surriel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton
	 <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>, Andy Lutomirski
	 <luto@kernel.org>
Date: Mon, 29 Jul 2019 12:10:12 -0400
In-Reply-To: <20190729154419.GJ31398@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
	 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
	 <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com>
	 <20190729150338.GF31398@hirez.programming.kicks-ass.net>
	 <25cd74fcee33dfd0b9604a8d1612187734037394.camel@surriel.com>
	 <20190729154419.GJ31398@hirez.programming.kicks-ass.net>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Wc6jN0+BMJTfEPLvJuKE"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-Wc6jN0+BMJTfEPLvJuKE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-07-29 at 17:44 +0200, Peter Zijlstra wrote:
> On Mon, Jul 29, 2019 at 11:28:04AM -0400, Rik van Riel wrote:
> > On Mon, 2019-07-29 at 17:03 +0200, Peter Zijlstra wrote:
> >=20
> > > The 'sad' part is that x86 already switches to init_mm on idle
> > > and we
> > > only keep the active_mm around for 'stupid'.
> >=20
> > Wait, where do we do that?
>=20
> drivers/idle/intel_idle.c:              leave_mm(cpu);
> drivers/acpi/processor_idle.c:  acpi_unlazy_tlb(smp_processor_id());

This is only done for deeper c-states, isn't it?

> > > Rik and Andy were working on getting that 'fixed' a while ago,
> > > not
> > > sure
> > > where that went.
> >=20
> > My lazy TLB stuff got merged last year.=20
>=20
> Yes, but we never got around to getting rid of active_mm for x86,
> right?

True, we still use active_mm. Getting rid of the
active_mm refcounting alltogether did not look
entirely worthwhile the hassle.

--=20
All Rights Reversed.

--=-Wc6jN0+BMJTfEPLvJuKE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0/GmQACgkQznnekoTE
3oN1Mwf+M8ilckJKazPB0sap6Gw+VcoPa1Ij8YnYtR0OIXGLktOKIWlJY9b3hYfY
Gn4yYJDoz1z8seaj6Ww+spOBzCxlS9qJlRxSqbijqR9zS4pC19y22l6OUfVPX0AO
zXirw8e+2OSbVcb26eAe4pzamJtW0kmf9YQgxJ545nZo4xV4uJ1FyJGKxL9OyJdR
/0JS1Vdi9Nlisa7YQw61k2USbGyFROvO3igHf5ii/2M2Rk1JictO4cYSfQrMYBy+
B3R3zlc0v5bNVl9MnBw6AjQs/sseEY/912Vzrsss05OyLI6zgmgsxBF+xsiEGsQW
nVdkkuBHbSQwKIQGKfM+JzF/F+ltrw==
=TidT
-----END PGP SIGNATURE-----

--=-Wc6jN0+BMJTfEPLvJuKE--

