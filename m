Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23950C7618F
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 02:56:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C85C020659
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 02:56:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="eMQaGK35"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C85C020659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C57A6B0003; Fri, 26 Jul 2019 22:56:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 474728E0003; Fri, 26 Jul 2019 22:56:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33C328E0002; Fri, 26 Jul 2019 22:56:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 106AE6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 22:56:23 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l9so49006189qtu.12
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:56:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=b/g/UkQMvOsg1N0rbY/yySPTGMQNY5F8dTERfSADiKQ=;
        b=D1IRYKonaOFVj/B1opWkK7/uiZkXai0dxz7hkgcsSy1jQ4Ic22TY6n6QyzG5dOMCNQ
         3Wy7lQAbEUSWMH+5iCrP9fPD+ZRy/vw2iNfkF4mXSgEBkdcGDOeRmlIL0MUWOSudR9Gj
         f6sHGP1dQv3tcDXyR1X80AursOfy/yhUPpPkBlvUw6QJGutrpVKhxzrtun8GE5+U5FdU
         9ctBe7czbJiwJAZqjUkwWGHgNrU4GTUiB91o6fLQaEqPkeGEaTDgr23a4RxFgwoEiudq
         UfUTD2/5g8TIFEuQ12meDiY1vFAV0wf/So1eJtQAcNqfo728n5a5M57pN3H6ET/08lzc
         nzhw==
X-Gm-Message-State: APjAAAV/16dRFaFXK6mLVJveoQERtqvdruIMf1d9+pqEabgHweNu2QMy
	WjdhVjH++seSCQcdF6L667DAvxJ/AEdtEM7NAxYGDZ5WN3L/zJhrJTWx4y6AeCFg6txgW67HtY0
	iR9cXLlNvjjoNzJIkQU9pbgLt/4VBlbMOIimJBP2lylqFWGYa/2OdGjV9ARtEsrgxLw==
X-Received: by 2002:ae9:e306:: with SMTP id v6mr64512565qkf.145.1564196182803;
        Fri, 26 Jul 2019 19:56:22 -0700 (PDT)
X-Received: by 2002:ae9:e306:: with SMTP id v6mr64512548qkf.145.1564196182224;
        Fri, 26 Jul 2019 19:56:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564196182; cv=none;
        d=google.com; s=arc-20160816;
        b=OJIhsUxtGsxRvLfMWmtg4IJWST49IWiQ2jKda0wlp6YcfuUSkmiCSw5AzOyQyx2sey
         Npxr/GvEzbvn00I5VXYHwfjiFOn8N7lliNTrxOieTTChnJc8Gx4nD7vwyxEuf5UZbEFK
         4HX1VPopt0gnGbdnE2beK/eH0OLaiMq2AaJwrbY41wRzBYFibjX4UeBF9Q00RFMPwcUD
         vTiHmmT4niyPAFgsWYSV2/ZbrllYUVlgSpuPMkVYu9JUSxMqOwxcOvixBlF2C51dW3ZV
         FFvR7KlFT0nDO24XOxLHMFL2W94d/CakpVxGvEepuYOJXrMsCbg5m9heN+yIYZj+/HXb
         b4nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=b/g/UkQMvOsg1N0rbY/yySPTGMQNY5F8dTERfSADiKQ=;
        b=HbDgGFnwnE+/MIsbo9sRXbfuLIPFEic2HPuK9+vuPT8ZIu0vxQ/UDM7LJVs//7YycY
         o1dWGdD6SvjmjN0XnpAKL/PbS93GnK4VOdgqF0dwbU8GW0gGr8Xq1E7ACxyCXMd0rnZe
         px4gO1p+aaqc1WLKBAnFzgNqNxtsFr2NJb0Jk9X7dt6diW/tlKym232Qziru1AXeNeb7
         57GtykBoa/IIYmVKZuQJdkxoyDGiVkaS2w0QwTrzA5cbkua//WAkQzHDyGFJU6zgoYFl
         QEJAvA8FeqZEfG6PHNHGsz0WxaXvMwW+V2ZtlMGNMqiIax2srsaCHyCUm1qE2MEM5BdF
         LiNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=eMQaGK35;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q18sor28745321qkc.80.2019.07.26.19.56.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 19:56:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=eMQaGK35;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=b/g/UkQMvOsg1N0rbY/yySPTGMQNY5F8dTERfSADiKQ=;
        b=eMQaGK35dCJBd/0p+TnvHHYFPeX+5bAbP3P+lOGrohXSgf0UD+zb4GX1wjJUaUalFw
         xP/ktfqhdDXRXBgu3kHNwSdBC4wcnJU2HQqO3AwoaqQZcb+YCTcIGTbVrXlmfPaGDDw1
         u1zoRgwf+jJFVZEl8UGmZ4M6zJKyoszU3Lc9r2VNvtweL81sT87uWShaE+0L75AgWtQa
         gEodjoNCreMgSA0Iy2EK7ssDqIfHRju6uVuvzrEyVPLw2prglB9XzVvgqgHmWf5lGxAf
         yikXff4rCyszF7fcS6j0xm54AVhH135ZqwXOoOsfREkcQyRwtpehRvKSniGmoe3GUGIE
         omWg==
X-Google-Smtp-Source: APXvYqynQocQE4l7hBi/wmTypC83TazHSdyWCMed6qXNA6h59EAC1XNMJmP9bCMa5a4vj95oaIQkNg==
X-Received: by 2002:a05:620a:137c:: with SMTP id d28mr1857550qkl.351.1564196181742;
        Fri, 26 Jul 2019 19:56:21 -0700 (PDT)
Received: from qians-mbp.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id v84sm24822683qkb.0.2019.07.26.19.56.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 19:56:21 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: memory leak in kobject_set_name_vargs (2)
From: Qian Cai <cai@lca.pw>
In-Reply-To: <CAHk-=why-PdP_HNbskRADMp1bnj+FwUDYpUZSYoNLNHMRPtoVA@mail.gmail.com>
Date: Fri, 26 Jul 2019 22:56:19 -0400
Cc: syzbot <syzbot+ad8ca40ecd77896d51e2@syzkaller.appspotmail.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 David Miller <davem@davemloft.net>,
 Dmitry Vyukov <dvyukov@google.com>,
 Herbert Xu <herbert@gondor.apana.org.au>,
 kuznet@ms2.inr.ac.ru,
 Kalle Valo <kvalo@codeaurora.org>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>,
 luciano.coelho@intel.com,
 Netdev <netdev@vger.kernel.org>,
 steffen.klassert@secunet.com,
 syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
 yoshfuji@linux-ipv6.org,
 Wang Hai <wanghai26@huawei.com>,
 Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
 "David S. Miller" <davem@davemloft.net>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E20E1982-1F60-4F01-AE3C-0CF397A596C4@lca.pw>
References: <000000000000edcb3c058e6143d5@google.com>
 <00000000000083ffc4058e9dddf0@google.com>
 <CAHk-=why-PdP_HNbskRADMp1bnj+FwUDYpUZSYoNLNHMRPtoVA@mail.gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 26, 2019, at 10:29 PM, Linus Torvalds =
<torvalds@linux-foundation.org> wrote:
>=20
> On Fri, Jul 26, 2019 at 4:26 PM syzbot
> <syzbot+ad8ca40ecd77896d51e2@syzkaller.appspotmail.com> wrote:
>>=20
>> syzbot has bisected this bug to:
>>=20
>> commit 0e034f5c4bc408c943f9c4a06244415d75d7108c
>> Author: Linus Torvalds <torvalds@linux-foundation.org>
>> Date:   Wed May 18 18:51:25 2016 +0000
>>=20
>>     iwlwifi: fix mis-merge that breaks the driver
>=20
> While this bisection looks more likely than the other syzbot entry
> that bisected to a version change, I don't think it is correct eitger.
>=20
> The bisection ended up doing a lot of "git bisect skip" because of the
>=20
>    undefined reference to `nf_nat_icmp_reply_translation'
>=20
> issue. Also, the memory leak doesn't seem to be entirely reliable:
> when the bisect does 10 runs to verify that some test kernel is bad,
> there are a couple of cases where only one or two of the ten run
> failed.
>=20
> Which makes me wonder if one or two of the "everything OK" runs were
> actually buggy, but just happened to have all ten pass=E2=80=A6

Real bisection should point to,

8ed633b9baf9e (=E2=80=9CRevert "net-sysfs: Fix memory leak in =
netdev_register_kobject=E2=80=9D")

I did encounter those memory leak and comes up with a similar fix in,

6b70fc94afd1 ("net-sysfs: Fix memory leak in netdev_register_kobject=E2=80=
=9D)

but those error handling paths are tricky that seems nobody did much =
testing there, so it will
keep hitting other bugs in upper functions.=

