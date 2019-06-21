Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCC6CC48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:55:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8329E206B6
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:55:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZpPFzcp3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8329E206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16E528E0002; Fri, 21 Jun 2019 19:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 150728E0001; Fri, 21 Jun 2019 19:55:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 033428E0002; Fri, 21 Jun 2019 19:55:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1B348E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:55:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x3so4985290pgp.8
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:55:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=x9bZV3T0S6eNYo6IXHrd+kECvmTbbAucaYzxDYrbdeI=;
        b=mLOuVwjLpWeHhyQ4EXO05/mTQ1eFliCMYwQ/zP7YnI9xuJ/G8Oj1EVy+Ysx+IV+OaE
         TIg695mb7tJBf7jmcMYL1Nd9rceClp0800Hbykqx0iMZq4CyFevDzjaorRL0v25wBVL+
         dyG5sJoiS5GWsQOigrTF3jDkK21dGdEFMH/MOHsJPIh/smjtKhjKU3omZQ4dhHI6FBLR
         2R8HIU8u2XF1rJvnytIiM0i9GxdGSd9ZbanleW/w4YMHkBBNmG9q2XtEXGg7qlS4nc7P
         G3qxOQkfD7wISC2eTVPlIBuffXEPyt4KHcqDIiz584UPIiQDyVCtm4xbKLOkCsExDNgA
         WMLg==
X-Gm-Message-State: APjAAAUA34YDZ1QYYoVcRtcBGBKNyaHpSSTm7BJwTt+XZWYLEyHOvOTW
	acyyuqDFKzzkz7TstYCvJlLGgnPgBTR/9VVEaimno3m1wEEtus8/fbjEQ1TyimUPgEi9CG8ssPE
	zu5Ve7EMQoYCaMrUkt/jOCrAcJrfIF9etFGBdUukvbZTtzp8/rnJMaihYsYSBnyKHFg==
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr37754659plp.95.1561161326474;
        Fri, 21 Jun 2019 16:55:26 -0700 (PDT)
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr37754613plp.95.1561161325657;
        Fri, 21 Jun 2019 16:55:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161325; cv=none;
        d=google.com; s=arc-20160816;
        b=o3ydsOp+rwHxEEN4erTxSAL2VyJFSxfFnQBKGGCDRV2U8/I/PNKkU773KJPRX0Hu3q
         780v4LTFLQFwOplGPS6scCbzUVE0JNSs8REPzZksd7YVVGNlh/RbFkAciB8bpVWR113f
         rYF07G7cwlawWD2Inlu0X+RlNaEk/+sZvvdsZZmDlQ5eeMzQBijeL87yjw5J3KuD5p+n
         RK7zU8PdZU9Z2pvOWkqDzPAPeTVGnMt6fCWnCQyScjSempVSOj6/Sl7RZPdkATWehx7P
         d5rbsjAFSjZpzzXYhzuBN+u3XTI7iif8Tqj2np2A4nkG51jRbZfiOPgfnY/d6+kprmT+
         6W5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=x9bZV3T0S6eNYo6IXHrd+kECvmTbbAucaYzxDYrbdeI=;
        b=EdFU2F5os0Br6Ji7T89oMeYrZbr/b43NcnkLvLfWupVhaKTHwWU1sTrfE4Nwxu/2rj
         ulSJQTqmo95S/U4PVIyxMrdMEqOm0Cdod16zNjf61vLIuWNaF12U6FMRjgSnPeP8JsOB
         ac6FvWXRrvZrsZlId/YewvlS3F3YKRkks49HhgSMzgya0BFilb9aLIC5/nh9ZlHS8s+G
         TKwKI9eY6v6hhwtwUGGZP+9+Nwx7D2UWO5RptMw8Ytnex+5oyJDeoa/r7Pjku1RcHXhU
         4cPdWfGFLbpB+WcUM/PUnPaiViIJEq85X+sa65t7ZRqZdt1LfBcWBirIkAIAE7Zzhnoz
         vXng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZpPFzcp3;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor2724438pgo.60.2019.06.21.16.55.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 16:55:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZpPFzcp3;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=x9bZV3T0S6eNYo6IXHrd+kECvmTbbAucaYzxDYrbdeI=;
        b=ZpPFzcp36+Hh5jye0ZKjtgJ550NYI096FfX2rcFyQ99LOi8SMis6xF/dheI3yxj7vn
         TBGcbHMLdJQh068I90oszy1lxCnmI5g4KVT7DQMh+oL+mOljJTN2ljZWYTmOt23yVg2h
         LdyqXTNKqxAmKaI+JKi19peuQtNFJ/A6jfkfKGStmgPKTkapA12DT/MDePfRHMwpeCd2
         tgrx+S6ckAPgkEN6TA/783NZNMh/U4UZX0873+4sMF+NwUUbApR86gBQBtLXNIwieoaL
         GIkk0MteisbTCO2dsnPaZ8Qv7rsQ8XF4reLwhY4yUxl1spYYF0SWL0LStYP/hWINYrnP
         HtFA==
X-Google-Smtp-Source: APXvYqyqRRpjMOtRudskKnzHE+bVq170qVap7+EY5kc6j/qI6uUR3V4Zstw2KCShBoXYwoTuoCwbAg==
X-Received: by 2002:a63:545c:: with SMTP id e28mr4210785pgm.374.1561161325219;
        Fri, 21 Jun 2019 16:55:25 -0700 (PDT)
Received: from localhost ([1.144.144.251])
        by smtp.gmail.com with ESMTPSA id 85sm4623425pfv.130.2019.06.21.16.55.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 21 Jun 2019 16:55:24 -0700 (PDT)
Date: Sat, 22 Jun 2019 09:55:09 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 16/16] mm: pass get_user_pages_fast iterator arguments in
 a structure
To: Christoph Hellwig <hch@lst.de>, Linus Torvalds
	<torvalds@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Rich Felker <dalias@libc.org>, "David S. Miller"
	<davem@davemloft.net>, James Hogan <jhogan@kernel.org>, Khalid Aziz
	<khalid.aziz@oracle.com>, Linux List Kernel Mailing
	<linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, Linux-MM
	<linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, Linux-sh list
	<linux-sh@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>,
	Paul Burton <paul.burton@mips.com>, Paul Mackerras <paulus@samba.org>,
	sparclinux@vger.kernel.org, the arch/x86 maintainers <x86@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>
References: <20190611144102.8848-1-hch@lst.de>
	<20190611144102.8848-17-hch@lst.de>
	<1560300464.nijubslu3h.astroid@bobo.none>
	<CAHk-=wjSo+TzkvYnAqrp=eFgzzc058DhSMTPr4-2quZTbGLfnw@mail.gmail.com>
	<1561032202.0qfct43s2c.astroid@bobo.none>
	<CAHk-=wh46y3x5O0HkR=R4ETh6e5pDCrEsJ94CtC0fyQiYYAf6A@mail.gmail.com>
	<20190621081501.GA17718@lst.de>
In-Reply-To: <20190621081501.GA17718@lst.de>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1561160786.mradw6fg2v.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig's on June 21, 2019 6:15 pm:
> On Thu, Jun 20, 2019 at 10:21:46AM -0700, Linus Torvalds wrote:
>> Hmm. Honestly, I've never seen anything like that in any kernel profiles=
.
>>=20
>> Compared to the problems I _do_ see (which is usually the obvious
>> cache misses, and locking), it must either be in the noise or it's
>> some problem specific to whatever CPU you are doing performance work
>> on?
>>=20
>> I've occasionally seen pipeline hiccups in profiles, but it's usually
>> been either some serious glass jaw of the core, or it's been something
>> really stupid we did (or occasionally that the compiler did: one in
>> particular I remember was how there was a time when gcc would narrow
>> stores when it could, so if you set a bit in a word, it would do it
>> with a byte store, and then when you read the whole word afterwards
>> you'd get a major pipeline stall and it happened to show up in some
>> really hot paths).
>=20
> I've not seen any difference in the GUP bench output here ar all.
>=20
> But I'm fine with skipping this patch for now, I have a potential
> series I'm looking into that would benefit a lot from it, but we
> can discusss it in that context and make sure all the other works gets in
> in time.
>=20

If you can, that would be good. I don't like to object based on
handwaving so I'll see if I can find any benchmarks that will give
better confidence. Those old TPC-C tests were good, and there was
some DB2 workload that was the reason I added gup fast in the first
place. I'll do some digging.

Thanks,
Nick
=

