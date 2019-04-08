Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF1C6C10F14
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 17:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C1932148E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 17:32:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l5c7+WZx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C1932148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F14E6B000D; Mon,  8 Apr 2019 13:32:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A16C6B000E; Mon,  8 Apr 2019 13:32:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B7816B0010; Mon,  8 Apr 2019 13:32:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id DAB496B000D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 13:32:26 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id a17so2338268vso.15
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 10:32:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=ajZNHx/mikUePwu4fOF1edmFuVfA9nuB9PUv4B+gVXo=;
        b=mOYh3ja7AiCQ0jYujNke5JMTAAWNX180rQT9n0D1lct7B73w1rgEW/5rnrwpFemLdT
         DmW98gSW5jJT4rlgDXxQj2UU9TDwsvCbqcNn4mdB3J2NFvZ4W5IY8F4qpQcoa2xAOOMJ
         PUz2I8KucH/5z0yDyCSkyoegKLX02OK5N7IMMXFLsS44BGbCirxsHyNMM5jbGOhdvCRu
         y3L7sr2FMy4f3ku3m9iMVOd23XAndmD2luz2kFRBKIVFUbqSsWQufKfRHv1u3Y80JkuM
         dlE8RwKqj2FpL9YILVI7XVfQzrueyqH9D+LWSW9gezXrruSdB1qCp8C66BuK7eAoElTv
         Tnow==
X-Gm-Message-State: APjAAAUrQ5R1G/OgjIjokSO4TPeBsUwt72i6eA549U3UNltaMc26cotR
	J6weE0dkl5kST/6z6eOnA+T5M0QIKJ8WgNkKxnrNyrpryQsfwo/uYGjvrz5AohQ2UVHaxWKpjo2
	JAPQYjmMIMBfIWCzjWw7/RMjJM6Opj6QiSmmf+al6/4nViZ5eLtgEHHBSZazZTEPsjg==
X-Received: by 2002:a9f:2a8d:: with SMTP id z13mr16408978uai.62.1554744746432;
        Mon, 08 Apr 2019 10:32:26 -0700 (PDT)
X-Received: by 2002:a9f:2a8d:: with SMTP id z13mr16408922uai.62.1554744745476;
        Mon, 08 Apr 2019 10:32:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554744745; cv=none;
        d=google.com; s=arc-20160816;
        b=ZFMh+tDHS3fj8R0rOvdrZ9hI5L74eA30t/EUJd2J1KV8/U9b4+eOu6qe1R52lx0lD5
         CuKMhGo1SJ+P+W5YDE+R00VZqGNUwhcgSsY4AXS+TVFCB3WxZKiw7J81ZUf1J74+yM9x
         3HIxrV5QSNeZS0Ql23RTuI/rSv5p9R0lHa8FMu/3omi5+gN2ml9Xm8/6zlay7HYAZax1
         IqxHR7QEAX2Tbg08YYOL/pcfJJ8VmaXIMZ0xtvB5kJE5bmZaRJ1R+VoeCl6Y0gd1uM5T
         FFbw4GaXJLX30h8qGw8tgezsmRdZejuSZT3bu3exwPnHevEJ72E6GLsJlKdDHMy1GhZo
         7Erw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=ajZNHx/mikUePwu4fOF1edmFuVfA9nuB9PUv4B+gVXo=;
        b=lSyuOWUFqReZlnVfdEjqMVsKeL1OcF19Fg3sA8kVhxU6m5Bipbi8zIP/om2WlFTJr5
         +lB5uQvi/EYVo8TKFFy9Lxw5BVOrRMQB/GEBlj0d1srLRW4gqAjzY11pevR4IzBcp8h3
         5PfAlDvXd46cLU04tQJsXhFAyMRUyjc2E1K1KwXFwu4fR6GgyyWqG9EtrGIDcdPhOk2N
         5C2jrufYC7HI0uYsOvGRy/RAGCbn2r+Jio8FiUUlp+h9eE6WuZbsScv3tRK6YqIEqtvx
         VIa/9MIfDNCq33geJ1U/nj9K+piouzwwZ1dr7JqDA6NOyErCq0cZfUZcb4X0ABqQqv7k
         8vpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=l5c7+WZx;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j131sor18245427vsd.72.2019.04.08.10.32.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 10:32:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=l5c7+WZx;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=ajZNHx/mikUePwu4fOF1edmFuVfA9nuB9PUv4B+gVXo=;
        b=l5c7+WZx6MfsyrofU3Pmy0q97Z5nBitN+Sjxf5Co/Z3gGd4ZM+9A6ZrPKLJpZiaUTH
         CsHC4gWe26RJx5Rj/UZBbL2MlkhE+MymDeI/vwAlgwYHkwKkynao0I5iqOCjDUtfc1Qr
         VBR49ZvovNS62zVmW6RqcPaJvpBxAtB3pBQvRZXtDrQ8TkTRlOKvslA/5A+td08DI0P8
         285qCEVFrB0/MujELW3bVXp9gZHgM8hgy3To5BPt5qHUmiCKIht8IXVe1ZK8mWylUIGx
         e4h/0W05JgSUiGcPJOxfQzYFFKyUqLg8sW7howIrQVq0c61JPrNv3tNsGTn3pXy9e6V+
         9tHw==
X-Google-Smtp-Source: APXvYqxvoOvMGsdGQ57l/2vJ38ZLo/tTfijphZX/eefshUQXutbAVGd39edodapItVKrCZLbXwLdQqKszGePOVSp3vs=
X-Received: by 2002:a05:6102:3c2:: with SMTP id n2mr17487291vsq.41.1554744745049;
 Mon, 08 Apr 2019 10:32:25 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Mon, 8 Apr 2019 23:02:13 +0530
Message-ID: <CACDBo56tsSnb7aou6bRizhbcNneoOh+a07nAfvq3K9v_9z_HjQ@mail.gmail.com>
Subject: Memory Configuration for 32-bit, 64-bit and PAE enabled OS
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	kernelnewbies@kernelnewbies.org
Content-Type: multipart/alternative; boundary="0000000000003ec4b10586083832"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000003ec4b10586083832
Content-Type: text/plain; charset="UTF-8"

I am confuse about memory configuration, i have below questions.

1.if 32-bit os maximum virtual address is 4GB, When i have 4 gb of ram for
32-bit os, What about the virtual memory size ? is it required virtual
memory(disk space) or we can directly use physical memory ?

2.In 32-bit os 12 bits are offset because page size=4k i.e 2^12 and 2^20
for page addresses What about 64-bit os, What is offset size ? What is page
size ? How it calculated.

3.What is PAE? If enabled how to decide size of PAE, what is maximum and
minimum size of extended memory.

Regards,
Pankaj

--0000000000003ec4b10586083832
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I am confuse about memory configuration, i have below ques=
tions.<br><br>1.if 32-bit os maximum virtual address is 4GB, When i have 4 =
gb of ram for 32-bit os, What about the virtual memory size ? is it require=
d virtual memory(disk space) or we can directly use physical memory ?<br><b=
r>2.In 32-bit os 12 bits are offset because page size=3D4k i.e 2^12 and 2^2=
0 for page addresses What about 64-bit os, What is offset size ? What is pa=
ge size ? How it calculated.<br><br><div>3.What is PAE? If enabled how to d=
ecide size of PAE, what is maximum and minimum size of extended memory.</di=
v><div><br></div><div>Regards,</div><div>Pankaj<br></div><br></div>

--0000000000003ec4b10586083832--

