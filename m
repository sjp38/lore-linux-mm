Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA206C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 807FD2064A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:07:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 807FD2064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 175F18E0003; Wed, 31 Jul 2019 11:07:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 100708E0001; Wed, 31 Jul 2019 11:07:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F09778E0003; Wed, 31 Jul 2019 11:07:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCAF78E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:07:28 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id r200so58389830qke.19
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:07:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=6h6gUfLc5N0r1ACqpLSVgHZtCyHtC7RImQVmqauYd7Q=;
        b=n5SJ5+LEne0ZvHsCVs0lnuNwC5czv/yBNRALT3ku0OMymkw+9mZTBOHIXowX4ZomiH
         hFn5JXYnvUJxWt/kgGsJ3mYdJVWrkHTSoxbvhsHhlV/AV6nkFu9mlFEjXMKMOPAVDawV
         xlSt9UB938a17ytb+v/74ssN2RTHe2rpY88OHqfSzxFu8Gaswql26GlrrBc2CnGiriND
         gimp3HdDOkZWX1g49cOJ9+qxU/WAiQe8PdTN5SDT+Utkq3zofzF7eAPkq68ZBtLHwAem
         VWj39u/i6StyoOuPpkss49JkcRx9hTRu+2I4KPv16ZFW9e2JTtTW/CVKWUPOKdNb3g0x
         MA6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAXvQZJsDiER+BC2xcZ8q75xCKsEGLfaKsn5xVQZemmFpZer8y3x
	nsPGk26LZ/3+/hTcKkxUBXKde4VqcJKrkCb/Q73z4WIc24jm/KNbRL+rf2/Mkyl61vGkNAZD7fy
	+hEYFPTFIMMSvJpDtkMABx4z92iNzMiwGqpLoEgT+Lb2jnHYvZmmEKO7OyETAldhTnw==
X-Received: by 2002:ac8:2e14:: with SMTP id r20mr87888979qta.241.1564585648577;
        Wed, 31 Jul 2019 08:07:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUXYS7dC3E2WyyBlAB1jva+SMIH8RoWNZ/0udHHJRYylPRPOYySFXV00PwGMBr22N67rlY
X-Received: by 2002:ac8:2e14:: with SMTP id r20mr87888916qta.241.1564585647810;
        Wed, 31 Jul 2019 08:07:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585647; cv=none;
        d=google.com; s=arc-20160816;
        b=Ke+YyPkfsMd6IkLyGaxJFa5WhsQ0TYO7BsYBCEHcmt8E8560ivdNbS0vviga+hvWgF
         p5RvH5za4veESZWIGjUBXuuqvOyORtXZ8CzA1icpVRWyqC1UBTU4ocfdJBHUYvMrCgiv
         sUiggWvAvfPcRcTW1TbnOcentfzM62AfzmGqTGHtYU4eV0eEUTyTrAvQ56WTnJDzRsTV
         T2T7+6dANKE0VNflk52HH0N5xGeWvbjeoJDrlQSTkqo4W2gfH0VVnXXpe0MTf+/TXtVR
         1bS2AMsgetigAIJ81JVGN2rZjEiruk3XVkhzVg4gycELwipG1ivJVTSsQ2CrO+x7dMTy
         cnfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=6h6gUfLc5N0r1ACqpLSVgHZtCyHtC7RImQVmqauYd7Q=;
        b=XDxq8jqO+0NjCFlcNji2tGqnEf1NJIxVb8OEBIT2yCBhsaWOwdS4eWxVLKPByokfWZ
         xRXzsvqNyCL5R31AMl7dkV++xlF+D/LYZ5qQnnon6P+uZLKQ4rEGU3rszLx7ltfVYWB5
         6GdonV8Lr/OryiKL5zoxrkaUi/XvuueXd+iRqfeAl92MQ5CiLXBRUlVkCNUC3eH4ii55
         LE+n2K19f9o/tfioq3w2p5SW6nqnTp3TeIxLqc4sdtXSVGSFZ74I94x+wIZKqbY9+xIG
         k8JhRkskkUIjMO8OzoOskpfhQFeH7gmkRvqJ0EYAglhGkKGxGTV4sKZ+1tOd0ejg42kQ
         yHFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id o3si616558qtb.21.2019.07.31.08.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:07:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hsqCM-0001Qa-NS; Wed, 31 Jul 2019 11:07:26 -0400
Message-ID: <76dbc397e21d64da75cd07d90b3ca15ca50d6fbb.camel@surriel.com>
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
From: Rik van Riel <riel@surriel.com>
To: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
  Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton
	 <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>, Michal Hocko
	 <mhocko@kernel.org>
Date: Wed, 31 Jul 2019 11:07:26 -0400
In-Reply-To: <01125822-c883-18ce-42e4-942a4f28c128@redhat.com>
References: <20190729210728.21634-1-longman@redhat.com>
	 <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
	 <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
	 <8021be4426fdafdce83517194112f43009fb9f6d.camel@surriel.com>
	 <b5a462b8-8ef6-6d2c-89aa-b5009c194000@redhat.com>
	 <c91e6104acaef118ae09e4b4b0c70232c4583293.camel@surriel.com>
	 <01125822-c883-18ce-42e4-942a4f28c128@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-LA3XQyUFN0DfKhuFWUzC"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-LA3XQyUFN0DfKhuFWUzC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-07-31 at 10:15 -0400, Waiman Long wrote:
> On 7/31/19 9:48 AM, Rik van Riel wrote:
> > On Tue, 2019-07-30 at 17:01 -0400, Waiman Long wrote:
> > > On 7/29/19 8:26 PM, Rik van Riel wrote:
> > > > On Mon, 2019-07-29 at 17:42 -0400, Waiman Long wrote:
> > > >=20
> > > > > What I have found is that a long running process on a mostly
> > > > > idle
> > > > > system
> > > > > with many CPUs is likely to cycle through a lot of the CPUs
> > > > > during
> > > > > its
> > > > > lifetime and leave behind its mm in the active_mm of those
> > > > > CPUs.  My
> > > > > 2-socket test system have 96 logical CPUs. After running the
> > > > > test
> > > > > program for a minute or so, it leaves behind its mm in about
> > > > > half
> > > > > of
> > > > > the
> > > > > CPUs with a mm_count of 45 after exit. So the dying mm will
> > > > > stay
> > > > > until
> > > > > all those 45 CPUs get new user tasks to run.
> > > > OK. On what kernel are you seeing this?
> > > >=20
> > > > On current upstream, the code in native_flush_tlb_others()
> > > > will send a TLB flush to every CPU in mm_cpumask() if page
> > > > table pages have been freed.
> > > >=20
> > > > That should cause the lazy TLB CPUs to switch to init_mm
> > > > when the exit->zap_page_range path gets to the point where
> > > > it frees page tables.
> > > >=20
> > > I was using the latest upstream 5.3-rc2 kernel. It may be the
> > > case
> > > that
> > > the mm has been switched, but the mm_count field of the active_mm
> > > of
> > > the
> > > kthread is not being decremented until a user task runs on a CPU.
> > Is that something we could fix from the TLB flushing
> > code?
> >=20
> > When switching to init_mm, drop the refcount on the
> > lazy mm?
> >=20
> > That way that overhead is not added to the context
> > switching code.
>=20
> I have thought about that. That will require changing the active_mm
> of
> the current task to point to init_mm, for example. Since TLB flush is
> done in interrupt context, proper coordination between interrupt and
> process context will require some atomic instruction which will
> defect
> the purpose.

Would it be possible to work around that by scheduling
a work item that drops the active_mm?

After all, a work item runs in a kernel thread, so by
the time the work item is run, either the kernel will
still be running the mm you want to get rid of as
active_mm, or it will have already gotten rid of it
earlier.

--=20
All Rights Reversed.

--=-LA3XQyUFN0DfKhuFWUzC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl1Brq4ACgkQznnekoTE
3oO3eQf5AccmrRMXxWm78tqusxi+4qeoJTYk0e55qTe9ICxJJM1GjyKCEok1mcRz
MKCKG1Gf6OMsZSp76dqQ3/WhbveHGMM7q+TBRqS3uKi2T+1kn3iPju0X66OYJ3jV
GCxf3mhuBwgbMAlJ/orHvbX0TUwE7yHnVWQOLU0PdivEvfA9FBU7LsnnDHhm8EzL
BSPJ1Qugfn7o9PrrFTGAARfEYQ2/ZHIhL3c1SZOfF6psCDIJaNJJbzCrUG12OVZU
eWZgt8mtpmozWRxZ+7s1UkYSXfIDOJQkRtHNcRtikonqBO3Tt/e8RFJBP5Rp0ond
HvpD66RQSO4zrn91S5EaUfnGmos7Zg==
=yJHK
-----END PGP SIGNATURE-----

--=-LA3XQyUFN0DfKhuFWUzC--

