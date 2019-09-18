Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 648DFC4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 20:00:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1725C21928
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 20:00:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Xl1Qun6E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1725C21928
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F98A6B02FD; Wed, 18 Sep 2019 16:00:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D96E6B02FE; Wed, 18 Sep 2019 16:00:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E7156B02FF; Wed, 18 Sep 2019 16:00:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0145.hostedemail.com [216.40.44.145])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE5A6B02FD
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 16:00:02 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CF85220BF5
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 20:00:01 +0000 (UTC)
X-FDA: 75949107402.10.eye13_74996f18e210b
X-HE-Tag: eye13_74996f18e210b
X-Filterd-Recvd-Size: 5452
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 20:00:01 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id g16so1249996qto.9
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:00:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=TgQ/PSk6s69IhIN3kvOl/nhDuvC2PFBPkZWWeBSDsGs=;
        b=Xl1Qun6EPEyvqTdKGERpDMNRYpTRFOq7YiV8XD0S2EmdmsptfOtLQd53pPMRs40OsP
         Zfy9SjE2m8yQ9aWYolH6euB+a9FwQpsK7Y2+IMqatO6MEdnrnCphSqpamfRBRAwMa/nW
         8vU3taJ1EUfiqL3F/p7jpVoT241bFVBCtNH22U5s8Ej7yj7vaQABp30uutX/vzYonf9A
         9lietmj1MbgOxYk5/tAT+6ERo8V7SOxyrePvTp4zvn3KLSn+JgvNajPuc5CGITRKlQjg
         yF174PcmWCm0KjNteIID1GoKRcbgW+VoVImpMVdVv2Pcx4CtCLT6ViBXF8Y8z5y6CXU/
         5IKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=TgQ/PSk6s69IhIN3kvOl/nhDuvC2PFBPkZWWeBSDsGs=;
        b=FDRiyFuleFtqSu9ESN4oEVrBEFGWZ/C32OgSYqTeX+0n4qCJ35TdniPOcEwJb429pP
         9eqseBdEOk8hUF+zdquSt5J8jqJYDKmYsQel1Mxz5xrTolfA3Txsmy0Y6G66sPp5Ib36
         oQ4/BR093Lji7CCxktdR9feL7yGNlhB67gktgS4zOsBy755saAy7VKL9NMUjm7SXznjw
         oxwg37Ho3XBYbJ6pgMiTkp+c3EvVa+nam1W9R30FEg/PwNp91VMjyv7WnXaSVVHPEURv
         R9z22NSBl8HQCQwA6sYbZcS4cZswU4LlkNnwNxP6SRvhwIbf9z8B9dpKT/zMAwKzhr0X
         mN5g==
X-Gm-Message-State: APjAAAWYefWd4tnIICkCtN403z+O5KdeQIEIqU23n+Q18ODfsbOcHA28
	ymLyeS3qPVox2t14YGWNXve+hQ==
X-Google-Smtp-Source: APXvYqx7ylgOdwTwai485piXcLjFj5zgpjU/OumbjBfWNGW3uR90d7CFqs4O9RiBxseGmXqWFaFurw==
X-Received: by 2002:ac8:16e2:: with SMTP id y31mr5909119qtk.370.1568836800501;
        Wed, 18 Sep 2019 13:00:00 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id q207sm3616779qke.98.2019.09.18.12.59.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 12:59:59 -0700 (PDT)
Message-ID: <1568836797.5576.182.camel@lca.pw>
Subject: Re: [PATCH] mm/slub: fix a deadlock in shuffle_freelist()
From: Qian Cai <cai@lca.pw>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: peterz@infradead.org, mingo@redhat.com, akpm@linux-foundation.org, 
 tglx@linutronix.de, thgarnie@google.com, tytso@mit.edu, cl@linux.com, 
 penberg@kernel.org, rientjes@google.com, will@kernel.org,
 linux-mm@kvack.org,  linux-kernel@vger.kernel.org, keescook@chromium.org
Date: Wed, 18 Sep 2019 15:59:57 -0400
In-Reply-To: <20190917071634.c7i3i6jg676ejiw5@linutronix.de>
References: <1568392064-3052-1-git-send-email-cai@lca.pw>
	 <20190916090336.2mugbds4rrwxh6uz@linutronix.de>
	 <1568642487.5576.152.camel@lca.pw>
	 <20190916195115.g4hj3j3wstofpsdr@linutronix.de>
	 <1568669494.5576.157.camel@lca.pw>
	 <20190917071634.c7i3i6jg676ejiw5@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000155, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-17 at 09:16 +0200, Sebastian Andrzej Siewior wrote:
> On 2019-09-16 17:31:34 [-0400], Qian Cai wrote:
> =E2=80=A6
> > get_random_u64() is also busted.
>=20
> =E2=80=A6
> > [=C2=A0=C2=A0753.486588]=C2=A0=C2=A0Possible unsafe locking scenario:
> >=20
> > [=C2=A0=C2=A0753.493890]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0CPU0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU1
> > [=C2=A0=C2=A0753.499108]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0----=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0----
> > [=C2=A0=C2=A0753.504324]=C2=A0=C2=A0=C2=A0lock(batched_entropy_u64.lo=
ck);
> > [=C2=A0=C2=A0753.509372]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock(&(&zone->lock)->rlock);
> > [=C2=A0=C2=A0753.516675]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock(batched_entropy_u64.lock);
> > [=C2=A0=C2=A0753.524238]=C2=A0=C2=A0=C2=A0lock(random_write_wait.lock=
);
> > [=C2=A0=C2=A0753.529113]=C2=A0
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0*** DEADLOCK ***
>=20
> This is the same scenario as the previous one in regard to the
> batched_entropy_=E2=80=A6.lock.

The commit 383776fa7527 ("locking/lockdep: Handle statically initialized =
percpu
locks properly") which increased the chance of false positives for percpu=
 locks
significantly especially for large systems like in those examples since i=
t makes
all of them the same class. Once there happens a false positive, lockdep =
will
become useless.

In reality, each percpu lock is a different lock as we have seen in those
examples where each CPU only take a local one. The only thing that should=
 worry
about is the path that another CPU could take a non-local percpu lock. Fo=
r
example, invalidate_batched_entropy() which is a for_each_possible_cpu() =
call.
Is there any other place that another CPU could take a non-local percpu l=
ock but
not a for_each_possible_cpu() or similar iterator?

Even before the above commit, if the system is running long enough, it co=
uld
still catch a deadlock from those percpu lock iterators since it will reg=
ister
each percpu lock usage in lockdep

Overall, it sounds to me the side-effects of commit 383776fa7527 outweigh=
t the
benefits, and should be reverted. Do I miss anything?

