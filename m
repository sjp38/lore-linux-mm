Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=FAKE_REPLY_C,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1343C04E87
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:38:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 637BC2082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:38:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 637BC2082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAE756B0008; Wed, 15 May 2019 04:38:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5E376B000A; Wed, 15 May 2019 04:38:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99ACE6B000C; Wed, 15 May 2019 04:38:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 51B096B0008
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:38:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z5so2787365edz.3
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:38:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LwJDAGbve15vlDYgOlwFsVsXGiCcKRyIKVqUUOu1aWs=;
        b=oovMQ2mR/wCsg0xr9ZYEJsAQEMSwZw9snJtxmi/E0Uop1g7037zmOfpkix+s3wPUam
         iy0RIgtwXyE9WgsoxN4o1NnWoBHzs4p+KCL28zb6Rhy4oiAzTGf22yEIzcogGBY44lpa
         RAc/DK06DakwiE/49zhoLzOT8ShUtnEHyp0N2S9149U6ykgsJmyCgpRpHUUDxmAgBYpq
         vf70CtLceNIH7PdTBZ5hJhP79C5Df82vlwuFbfA2+8LZ6YTP2LmTVqFaWVGYDH9CC/AS
         Uk1gM3dmT7gVruXIEa3Zeko3+1ial03Cs+T/xE1zV9URGXSA5npGWiiHL+biM4papFhV
         UqZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAWx9TfKvJ3TmraeWMnbPSVouFmaWZR/v18UgeU5UOOH0igts94g
	b+JdMqc67KJe7DfVsVCt+DmYNer3hvNmsHN3d4uUQtT4DT06XMZmntUHcm/zF/vv2EyfaVO/u3U
	1fTHk8C1jO29ojmWILZu7afMI8C+Ha3D0yM6zvEn3cER+i/oGG+9DQ7i7swG2LnWHwA==
X-Received: by 2002:a50:a91b:: with SMTP id l27mr42269020edc.31.1557909509931;
        Wed, 15 May 2019 01:38:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMP5dDzNseeT4TaY4La6amz2o7R/4QGAATi9jMrFe3FHTZnvyQy6OglUT8ak1AaMzDtaj2
X-Received: by 2002:a50:a91b:: with SMTP id l27mr42268967edc.31.1557909509223;
        Wed, 15 May 2019 01:38:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909509; cv=none;
        d=google.com; s=arc-20160816;
        b=sB8aQwuSchHcwZRhovyErrpvh2WJs82uJbJIT2bAFGvCU4XPVKs5coCVv5EHr60ifW
         zV2x2QCrWpXGmzB2Z+cEhd/5iWLt+erB6n8ttYLubgZEDs/poBTewh1Vg/oVb8BbaPWa
         hlGMmVKE8HjKAiA6q5LFNGW7hXYsIlGy8CrYPsYMfs/KHD4rTuZzciHqAWL/9J10/2Cv
         TYGHvpzJ+WGIyu/94Gt7uGXd8kOhaTovNzeoluXJSPEjXAMwWXlWm1Znf8p6LsYTAn0U
         UJiEHzH9BzXsT/hj6PEY0Z+vGDIpzVNuWTmJOq1G/gVgUxV+8krrfkjmA7ooqcDdW9Yb
         9+QA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date;
        bh=LwJDAGbve15vlDYgOlwFsVsXGiCcKRyIKVqUUOu1aWs=;
        b=EuIRNxRLqDdx+x1X6vWwdqX7o2PKu+Dsp4/mtVTcNmy6UfWpjnJrjPGf5injmCREGY
         z1oV8trgjiokcEgB+9OcnrLcbTk7XiZM82K4u4RPMUo/Ymtb/9eC6G9vdi425Up7kKiS
         ytDGOty0EPkzmrejF3oXGzVLbaV2S6IIewT9As5rgwLzeFeDcjA0uA377KVJMt9wP7zF
         CPKcTplsBWaR6rXi+w+89YsVV7dbvscR0GUYIni84qZVYglKd7e3FrijHj8++IguiKRh
         HshiZAio69gWdGqdr/ZP/f/SuKm0y3NTq4FtIXYJ2MGmZhikjmLtOvGWWJ11N1EBdoBQ
         /XGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t45si958228eda.235.2019.05.15.01.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 01:38:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B52BAAF95;
	Wed, 15 May 2019 08:38:27 +0000 (UTC)
Date: Wed, 15 May 2019 10:38:26 +0200
From: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
To: khlebnikov@yandex-team.ru
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, oleg@redhat.com
Subject: Re: mm: use down_read_killable for locking mmap_sem in
 access_remote_vm
Message-ID: <20190515083825.GJ13687@blackbody.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="451BZW+OUuJBCAYj"
Content-Disposition: inline
In-Reply-To: <155790847881.2798.7160461383704600177.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--451BZW+OUuJBCAYj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,
making this holder of mmap_sem killable was for the reasons of /proc/...
diagnostics was an idea I was pondeering too. However, I think the
approach of pretending we read 0 bytes is not correct. The API would IMO
need to be extended to allow pass a result such as EINTR to the end
caller.
Why do you think it's safe to return just 0?

Michal


--451BZW+OUuJBCAYj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEE+amhwRV4jZeXdUhoK2l36XSZ9y4FAlzbz/sACgkQK2l36XSZ
9y72Dw//WSCQl+uR7hQKCcZgc6M3EGW5FhKKiFTfagIYPeGFx8co6rAG2XFCBn89
PiCHJjcjY5BtRaCnLV/AmLbSGSj/j7aX0FIM/nKkP7z78HTrSBjkd30HIXV1Vig8
wQY4JGC5bK2rUkd/D5Fjjrg93wMvwRfyj3wZ6/dXObPU8tfbrbOTeD+JNFlk1WZf
WitkTbX3mD/xC3P3ItZ9+mTRXK+0MCMu/Bazf90yDFRB2uXvA788CTGVzsqzyfpG
vkZmBDTzT/jJJhYKd4gR4ecaQbD3zzZdJiz5AEZFGJFSpK6nwYXz9jarjIWP2T6e
OSZ4mGj+RjL3YBk9sqNgHPXMMS6IQoIgbpjVxwQlNN+6sSfGVm4qVGLn5N+69LwR
iQtCQSv2JS5afnWSaahWQsxzvmkE/6OC6Qs1D1EdclP7ph1PgrkV2NJ+0VVBZfRA
m0VNzZ6APLLoPc7yGaBP36yw6pjgycrVQaDtgZa1hqf1bpLnoqwrSlUQTTN2475Q
ig/ZEnDjlB/X85OkdEB26SLw5CtH35EL64DhfNU9l1dZ5Ygw5O4nOevkPwL2XC3F
mtftFgxxtFN2zDqg3s5gz7K5AAef7jn9TySNze2l7OVFwfpd96b8SXfyPxRMOgcy
aUFG3qyAdXEoPQHQPWtTrKsnhbu+qNCaIbhxZAL9j5iVKnHc/cA=
=vcUI
-----END PGP SIGNATURE-----

--451BZW+OUuJBCAYj--

