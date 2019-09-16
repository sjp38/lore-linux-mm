Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74AFCC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:01:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3636B2067D
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:01:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="P7J9rXIw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3636B2067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C69D86B0005; Mon, 16 Sep 2019 10:01:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1B816B0006; Mon, 16 Sep 2019 10:01:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B30C76B0007; Mon, 16 Sep 2019 10:01:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0072.hostedemail.com [216.40.44.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90F906B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:01:31 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0C3682C18
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:01:31 +0000 (UTC)
X-FDA: 75940946382.05.watch82_4754d05f4ed3e
X-HE-Tag: watch82_4754d05f4ed3e
X-Filterd-Recvd-Size: 4135
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:01:30 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id z67so36347595qkb.12
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:01:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zh1bX/1pt4TvUaavYlPJEShmROopWHh3ioE9bzCUP2M=;
        b=P7J9rXIwnfzfF/WxR2mtgZBrbVFC0dfwlxMJGL81H0Iul4qihss7GyFcYxVVEX1Q8J
         kTtes2RCYeJhBhcVH9c/pOTRJciW4XYPOiEZDjunGiVzwO1hOii9eyUB31UkR8nAV2W4
         rqahpuZxN7rX8MtGrc9t1HrOP4J+rLrMqmV+Lk8BY6mviYqkM7C31exC4HKvPV+0Xoku
         DRnjDPE+Oh2tHlpLEQDLcQqonEsY0EhzufbAyml+xC8h/rzV2Z1+bMxPo/2v117MdH3P
         zbV5t7g/31TJrsxgtbRt3Zo077SpaVlTFoo7gqQwz91+rIVDS2vNNc6DRORFBOORWNUF
         yqFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zh1bX/1pt4TvUaavYlPJEShmROopWHh3ioE9bzCUP2M=;
        b=QgdUbHBwfsvRK03+EjtZMx8NIF0LiYhpfOhGzj/ZBYw1uI6j0+b2Mj7m4RyUvNrgR3
         tQlq29o5YHHTq5qo6P2I6FZLm7Uzrl/OMMCpYG/Z2mPCT/+YE++JrAldx2jiDFb65hdf
         urUfLuyxkNwBvPWUezw6gD+peXVJMmyYKatV4jRx6HEceUYz8CudhKywT8nANZTdW9Nz
         vcztbIC04SXQbXGqT6WgjJ63ocorTvg3+iCevaFq0sfWM+3UHjX5FlC3ae1iwR20+5kj
         x24burBm04p59MKjpEYamP8qtNsiAFW4cvIkPQAamxMwi1bw8/LYoyWrlMRnBE1z01tm
         M2ng==
X-Gm-Message-State: APjAAAVU/grk9miQHAzKA64OcNBfGozYgi6s3KTBxGzABESqjwTtL9uH
	74lCgfPo+sn3tdSAuTv+aBeP4w==
X-Google-Smtp-Source: APXvYqwuBCZ2NutJluSdfnmZwv5tJRl2t2BmHssSEPJ5DNdSJIRusGDB8RsgrPPn1JrYcTVmWdTVcg==
X-Received: by 2002:a37:6554:: with SMTP id z81mr43102qkb.107.1568642489481;
        Mon, 16 Sep 2019 07:01:29 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id i4sm12548097qke.93.2019.09.16.07.01.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Sep 2019 07:01:28 -0700 (PDT)
Message-ID: <1568642487.5576.152.camel@lca.pw>
Subject: Re: [PATCH] mm/slub: fix a deadlock in shuffle_freelist()
From: Qian Cai <cai@lca.pw>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, peterz@infradead.org,
  mingo@redhat.com
Cc: akpm@linux-foundation.org, tglx@linutronix.de, thgarnie@google.com, 
	tytso@mit.edu, cl@linux.com, penberg@kernel.org, rientjes@google.com, 
	will@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	keescook@chromium.org
Date: Mon, 16 Sep 2019 10:01:27 -0400
In-Reply-To: <20190916090336.2mugbds4rrwxh6uz@linutronix.de>
References: <1568392064-3052-1-git-send-email-cai@lca.pw>
	 <20190916090336.2mugbds4rrwxh6uz@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000062, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-16 at 11:03 +0200, Sebastian Andrzej Siewior wrote:
> On 2019-09-13 12:27:44 [-0400], Qian Cai wrote:
> =E2=80=A6
> > Chain exists of:
> >   random_write_wait.lock --> &rq->lock --> batched_entropy_u32.lock
> >=20
> >  Possible unsafe locking scenario:
> >=20
> >        CPU0                    CPU1
> >        ----                    ----
> >   lock(batched_entropy_u32.lock);
> >                                lock(&rq->lock);
> >                                lock(batched_entropy_u32.lock);
> >   lock(random_write_wait.lock);
>=20
> would this deadlock still occur if lockdep knew that
> batched_entropy_u32.lock on CPU0 could be acquired at the same time
> as CPU1 acquired its batched_entropy_u32.lock?

I suppose that might fix it too if it can teach the lockdep the trick, bu=
t it
would be better if there is a patch if you have something in mind that co=
uld be
tested to make sure.

