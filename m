Return-Path: <SRS0=llCs=VE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFB76C48BE1
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 15:40:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83FDE20838
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 15:40:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="er0xymwp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83FDE20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE1E86B0007; Sun,  7 Jul 2019 11:40:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E906F8E0003; Sun,  7 Jul 2019 11:40:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA6438E0001; Sun,  7 Jul 2019 11:40:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF1FA6B0007
	for <linux-mm@kvack.org>; Sun,  7 Jul 2019 11:40:55 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s9so12852030iob.11
        for <linux-mm@kvack.org>; Sun, 07 Jul 2019 08:40:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qwHbQTuFE2kUikky3tbT6iwWg4yYSI3KMwntAKoTe4o=;
        b=Xtby0YitfhU9VP+moUWOKTFCew9ZRsddpwZBtGL/S3I2XDFRhz0NPwyWiPZTWfBmvq
         7MJU6hRe0OpWUKjW2l6bx4leHB0cEFskiQQZwtcuMKdXGndcKjdyfYXEGKKuJR798P2W
         m97SNiTMoaDSymQOXJqVg7P9yc9jLmuoPS3ispwRU11EGhcL3IEcepGXXjo8TYXUZ6zj
         XlB8xjjgQHnkqSY4SgqFuTJ5hN7qMBm6NpqGIYtH24qjnykC6mNwqbbaWva8B+2l6+bM
         Nncc8ubIadWCSlvkdMzXBXuQSGXxqV82TnJ08FO9aMQXvvjDUEuc8JEhDKacgWVnfQEj
         26fQ==
X-Gm-Message-State: APjAAAXoXJ5gqEyE+B42/Rx1ly3dHqe9vNNNdsI5OARX5xO3ZFilbSzO
	I90EEvAvKLuGKJotcKrrigNKJTYvBcJ1dddVb0OjxPOmpb9VcVEXN4Fj3hCCfjkx4S7r91lPxda
	88zhNbKKn7w7J2YwPIt4CbbWzres+6gkX/6UONKG66kTnu9SbdyXTxO6DF9Sms+QXqA==
X-Received: by 2002:a02:6a22:: with SMTP id l34mr16463397jac.126.1562514055504;
        Sun, 07 Jul 2019 08:40:55 -0700 (PDT)
X-Received: by 2002:a02:6a22:: with SMTP id l34mr16463353jac.126.1562514054872;
        Sun, 07 Jul 2019 08:40:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562514054; cv=none;
        d=google.com; s=arc-20160816;
        b=HI41xOs7pi15QIwHsyh3y6L2Pw2Bw2KxhoLF82/klNbiRUGIe2kRzBms9SiRKG9bms
         WESs/T6VRTzxskHErTgDVEI/peLsvKA2QSjBXPr6PoMeyqMDocvjAScvjLKi1F+udDPy
         4po7vqQiXJZy8fvy6GpjD5Pf6PxEgqDR1oIYV3rpcaoPFY6VGvFXBs08BOoDxsW3Kdwh
         QAH1qRTPmqRcV65YaUsIx1xtSAK4e8mprq+2coPueHgnvpUQL4HTw5SJ3rHtwfjbtqb9
         GGT8mU+utc6vpBiuPKzP4OpryAE7/b16Ey0irZmHZlbzeLCr7NXwSfFolcOR0J7RxTt1
         e7fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qwHbQTuFE2kUikky3tbT6iwWg4yYSI3KMwntAKoTe4o=;
        b=sBlrSj1KKTgypTDRpDgFQXB3hYl75LobIg7NmoqPsn2D+fsnjpf7zy53bRegM1P3ZY
         DoT92/staUTFzISMH+pqbOQ8dZqh/wQKK6reYHdG29A7fmacNhBsLBp/7/YB+2TM9r11
         wh0n2TDWKxtqaxFKFov8RJPyVWfkboKQPxheR3pV77cOO9Br7cfPBs27T9LAtxQ/S05Q
         vL/gtlR2d4mxEF33tnQN1b4XhJnMlv93FqxAQezT+DV3Hvzsm6Bvo2kuqglH6lC02EjM
         Eh3V4Z/zQoPzxiNePKwouJOhpZqG8i1KuMvuI2NDHzz5Hfu2IHBRKr/gDqb1t5HQUqel
         efNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=er0xymwp;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h25sor10173393ioh.29.2019.07.07.08.40.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Jul 2019 08:40:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=er0xymwp;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qwHbQTuFE2kUikky3tbT6iwWg4yYSI3KMwntAKoTe4o=;
        b=er0xymwpwDu18o30aSZDPXm6ih4bYYK56Lsn0PBrEBsI2+GkfvJ0DLnQK2RVcNhiay
         +D/JD05yJ/wS8a98UDAA7JmIXiaidvPOMnU2vGyMoKdb1jtHeCtBC3kmXqU8R3Q228vG
         68XGAd7WFcd9HF8yqcBoPhLbNT6Ry5i5f0EVkcB7o8FeikeNs/fXuQT4mDrR8/glCN+Y
         olzFtTyNcreomoJ0mN7e/JWRCYVoCfOG9fLdGpi1ajzyeGmzLMEJxRge1NuGQzdqnECA
         z47rAAdunWBGIzPrvt8O+hq21Hog6XykpUYRgPx2NN9dX9m4ijMVEhbxacAQadi+J3vO
         uUqw==
X-Google-Smtp-Source: APXvYqzuxGF7GLEefBfbdxPUSlLxOABw/jdkNTyIlCf5RzRx9gAPfKtK85ODjRIpvEtMUdMrKQuPQCx7Np6eky+RxpY=
X-Received: by 2002:a5d:8347:: with SMTP id q7mr13181248ior.277.1562514054357;
 Sun, 07 Jul 2019 08:40:54 -0700 (PDT)
MIME-Version: 1.0
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com> <alpine.LRH.2.21.1907061814390.24897@namei.org>
In-Reply-To: <alpine.LRH.2.21.1907061814390.24897@namei.org>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Sun, 7 Jul 2019 17:40:43 +0200
Message-ID: <CAJHCu1KPkzREqq0pGJ6Wp4CKHkA0Eeaj2vcGViE+B0192tFWFw@mail.gmail.com>
Subject: Re: [PATCH v5 00/12] S.A.R.A. a new stacked LSM
To: James Morris <jmorris@namei.org>
Cc: linux-kernel@vger.kernel.org, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, Jann Horn <jannh@google.com>, 
	Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

James Morris <jmorris@namei.org> wrote:
>
> On Sat, 6 Jul 2019, Salvatore Mesoraca wrote:
>
> > S.A.R.A. (S.A.R.A. is Another Recursive Acronym) is a stacked Linux
>
> Please make this just SARA. Nobody wants to read or type S.A.R.A.

Agreed.
Thank you for your suggestion.

