Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E6D8C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:33:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3722212F5
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:33:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=163.com header.i=@163.com header.b="mQly/kqz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3722212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=163.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 232238E0008; Mon, 24 Jun 2019 09:33:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E1F38E0002; Mon, 24 Jun 2019 09:33:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AA348E0008; Mon, 24 Jun 2019 09:33:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2DD08E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:32:59 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id i16so5356927oie.1
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:32:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :content-transfer-encoding:mime-version:message-id;
        bh=ZtuXJBKL8JZI6ZcD4t/TJM9MlPRmDeIp7jSZT/RQHac=;
        b=sEeRSVJGtDyMZwcAjhEqUsNamx3NlPrvyjiv3zMi6ja55o9nWzrj5PyFuZtrK4X/rp
         xaEk2e15OG+iuoKZOqgCrX5tJkxZWjpxrpvpIKJSkBmjZXgmtknuQi4JxjS/MEi14ym6
         lynu4Fx8bhniiB5TVFJHHaB2gWt4eF7G+fLFa17CEHIrbNn4Txb10HLqy4quVpEQjvYy
         lHwblP3yORucC7Q6WAqdGifDyr9PUbdxDJfpJfmorqIkmaqCp+0m7540BMpI7gKRry0H
         oNqPi0aDpJcNb2uhPq/pPvaptrgVZcJ0xQwp3GZAMQrrabKWqC+ZJcw+qIwi9gQzhfmw
         GZqg==
X-Gm-Message-State: APjAAAUnIgknif+d3Cm8YHBcPH6jeYsrDXKPl9YRl0uHnOd04i2rl5d8
	pOiZmE/4vqTeOOkgzbTvjGF1W2byKiXu3gnkR3YlPhURpYYQHjL32MawmwPDlDE3Pd7gUO0EE85
	kmPCJL1+UXjO9oEjQT7Jf5wjb0fMRmi4dXOfOdFx7YUr5A2EVvM59XZ+xbNWXjYbTRA==
X-Received: by 2002:a05:6830:1197:: with SMTP id u23mr37452075otq.36.1561383179502;
        Mon, 24 Jun 2019 06:32:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhDm7eV1tNl2Ffl7Nwd3VyiBa5dH5P4y1XCYeTQnj+as8wPn3tyXEGj7ndsiPF5LwKzTlE
X-Received: by 2002:a05:6830:1197:: with SMTP id u23mr37451999otq.36.1561383178303;
        Mon, 24 Jun 2019 06:32:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561383178; cv=none;
        d=google.com; s=arc-20160816;
        b=wtnQzyJB95mdXRCY+rHN4GtcLr3TFUmZ6pIulAABbuoiGJA7xe0l1H/mIBu7afDm+c
         gJ31z1g85Demk/AS6dP5wy9VdQapxvCzPyK4Czyfu9T8z5Hz7vidaL8pcB4X2BFSw14j
         nFil5bks0ktVg3JYCIOK9wqdxjENmAYwxTlNp7eiR/hB6cC5nBZREKnzCyqckZRsZn93
         soKjbkPId6D/BGdio7NyteaylBeUdFNNpxLPvWrJclIIrH4f79uZZaEu5/E9enCMhRTm
         qHLphR8zznXQk1p8n88Qf1v3Dr6jBEoQ0t3WvrvWccTui0pJ3klj/Bs0D7VTBOt40HSm
         jtUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:content-transfer-encoding:subject:cc:to
         :from:date:dkim-signature;
        bh=ZtuXJBKL8JZI6ZcD4t/TJM9MlPRmDeIp7jSZT/RQHac=;
        b=ix6oMCv6myr9YRJFYoYk9Ntv3vMQfFo7U9sXfxoYUhbOT43QTzYvLSDI2e2Jr/nYuc
         YOYlUpA0MQ3dl5Xdl7s6WB7Ts0ZXdXkod1yDfXzJE6caQFw0UXK52JqK0upqaPkimE/0
         dehxUs7RGyDO4CGMSsimofy1l8BdyX3Y7MbfmgrhyoPj6fR3udW3wTQsOUWtLx3cZGrQ
         jAORXixLJADJTaAAaYYOitlq9S7DVmMOWKw2gPSCZ71H71piKJQmtfwP9KQKN2iqBvnt
         TK+9vQ9FQeHlOd73cdzVAGXNBLhRcKd+1r+AK6F241u0PcqlTssPdjR7g1pKRQCBDgH1
         Conw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=neutral (body hash did not verify) header.i=@163.com header.s=s110527 header.b="mQly/kqz";
       spf=pass (google.com: domain of weijieut@163.com designates 220.181.13.129 as permitted sender) smtp.mailfrom=weijieut@163.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=163.com
Received: from m13-129.163.com (m13-129.163.com. [220.181.13.129])
        by mx.google.com with ESMTP id d65si6554729oib.140.2019.06.24.06.32.56
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 06:32:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of weijieut@163.com designates 220.181.13.129 as permitted sender) client-ip=220.181.13.129;
Authentication-Results: mx.google.com;
       dkim=neutral (body hash did not verify) header.i=@163.com header.s=s110527 header.b="mQly/kqz";
       spf=pass (google.com: domain of weijieut@163.com designates 220.181.13.129 as permitted sender) smtp.mailfrom=weijieut@163.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=163.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
	s=s110527; h=Date:From:Subject:MIME-Version:Message-ID; bh=aUGKt
	vZSy+6o0S9PVtKxbkzfcp42LXfJggJvKQBcobw=; b=mQly/kqzO1oiR3doEt8hS
	ppAyTx2uccPH4rQaW6E2hG79FGTcWdoLaP4/usBjKU2gFnZ6g0P1Qr5yI5bZGeqw
	nMLcNJNkKT9jAvWPUFg2jPFPiJ2mlOTez343k0d5uFJ+Tnw2Sd7t8QRdjMDgLSQz
	ZOuiDhAZpZrNIfxQpY2au4=
Received: from weijieut$163.com ( [121.237.48.209] ) by
 ajax-webmail-wmsvr129 (Coremail) ; Mon, 24 Jun 2019 21:30:10 +0800 (CST)
X-Originating-IP: [121.237.48.209]
Date: Mon, 24 Jun 2019 21:30:10 +0800 (CST)
From: "Weijie Yang" <weijieut@163.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: axboe@fb.com, fengguang.wu@intel.com, linux-api@vger.kernel.org, 
	"weijie.yang@samsung.com" <weijie.yang@samsung.com>
Subject: [bug report] read-ahead can't work properly
X-Priority: 3
X-Mailer: Coremail Webmail Server Version SP_ntes V3.5 build
 20190614(cb3344cf) Copyright (c) 2002-2019 www.mailtech.cn 163com
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset=GBK
MIME-Version: 1.0
Message-ID: <37a8bb5a.af8b.16b89adff5d.Coremail.weijieut@163.com>
X-Coremail-Locale: zh_CN
X-CM-TRANSID:gcGowADXbfJi0BBdeBX+AA--.3677W
X-CM-SenderInfo: xzhlyxxhxwqiywtou0bp/xtbBDQLdsFaD5oP5fAAAsX
X-Coremail-Antispam: 1U5529EdanIXcx71UUUUU7vcSsGvfC2KfnxnUU==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.011776, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CldoZW4gdHJ5IHRoZSBmaWxlIHJlYWRhaGVhZCBieSBwb3NpeF9mYWR2aXNlKCksIEkgZmluZCBp
dCBjYW4ndCB3b3JrIHByb3Blcmx5LgoKRm9yIGV4YW1wbGUsIHBvc2l4X2ZhZHZpc2UoUE9TSVhf
RkFEVl9XSUxMTkVFRCkgYSAxME1CIGZpbGUsIHRoZSBrZXJuZWwKYWN0dWFsbHkgIHJlYWRhaGVh
ZCBvbmx5IDUxMktCIGRhdGEgdG8gdGhlIHBhZ2UgY2FjaGUsIGV2ZW4gaWYgdGhlcmUgYXJlIGVu
b3VnaApmcmVlIG1lbW9yeSBpbiB0aGUgbWFjaGluZS4KCldoZW4gdHJhY2UgdG8ga2VybmVsLCBJ
IGZpbmQgdGhlIGlzc3VlIGlzIGF0IGZvcmNlX3BhZ2VfY2FjaGVfcmVhZGFoZWFkKCk6CiAKICAg
ICAgICBtYXhfcGFnZXMgPSBtYXhfdCh1bnNpZ25lZCBsb25nLCBiZGktPmlvX3BhZ2VzLCByYS0+
cmFfcGFnZXMpOwogICAgICAgIG5yX3RvX3JlYWQgPSBtaW4obnJfdG9fcmVhZCwgbWF4X3BhZ2Vz
KTsKCk5vIG1hdGVyIHdoYXQgaW5wdXQgbnJfdG9fcmVhZCBpcywgaXQgaXMgbGltaXRlZCB0byBh
IHZlcnkgc21hbGwgc2l6ZSwgc3VjaCBhcyAxMjggcGFnZXMuCgpJIHRoaW5rIHRoZSBtaW4oKSBs
aW1pdCBjb2RlIGlzIHRvIGxpbWl0IHBlci1kaXNrLWlvIHNpemUsIG5vdCB0aGUgdG90YWwgbnJf
dG9fcmVhZC4KYW5kIHRyYWNlIHRoZSBnaXQgbG9nLCB0aGlzIGlzc3VlIGlzIGludHJvZHVjZWQg
YnkgNmQyYmU5MTVlNTg5CmFmdGVyIHRoYXQsIG5yX3RvX3JlYWQgaXMgbGltaXRlZCBhdCBzbWFs
bCwgZXZlbiBpZiB0aGVyZSBhcmUgZW5vdWdoIGZyZWUgbWVtb3J5LgpiZWZvcmUgdGhhdCwgdXNl
ciBjYW4gcmVhZGFoZWFkIGEgdmVyeSBsYXJnZSBmaWxlIGlmIHRoZXkgaGF2ZSBlbm91Z2ggbWVt
b3J5LgoKV2hlbiByZWFkIHRoZSBwb3NpeF9mYWR2aXNlKCkgbWFuLXBhZ2UsIGl0IHNheXMgcmVh
ZGFoZWFkIGRhdGEgZGVwZW5kaW5nIG9uCnZpcnR1YWwgbWVtb3J5IGxvYWQuIApTbyBpZiB0aGVy
ZSBhcmUgZW5vdWdoIG1lbW9yeSwgaXQgc2hvdWxkIHJlYWQgYXMgbWFueSBkYXRhIGFzIHVzZXIg
ZXhwZWN0ZWQuCgpFeHBlY3Qgc29tZW9uZSBjYW4gY2xhcmlmeSBvci9hbmQgZml4IGl0LiAKClRo
YW5rcyAKCgoKCg==

