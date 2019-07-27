Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E33FDC7618F
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 02:29:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A165204EC
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 02:29:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="CqthdUK3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A165204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B51A6B0003; Fri, 26 Jul 2019 22:29:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23F3E8E0003; Fri, 26 Jul 2019 22:29:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12D308E0002; Fri, 26 Jul 2019 22:29:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id A188E6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 22:29:36 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id o2so12052467lji.14
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:29:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rRuVoGQyiTr9OUVJXnZ+mSEFCM9DeRijbw8KeVVr9qA=;
        b=R6ZKko6WQdWRODiW3+uigprqSiv6nwvw0qwbBokIlTRI2oFfuXUCSqvUNOi737TTGf
         ED/WbhKvSptUSRWmG6c0G5j9Q3wySD67a6W3rSHMT9ES+7C6TNqyeNsC9ouJy5EaomwH
         Tayv/EfhJlvQsh5dOr6h8y7FgohN/Xxc/peB4IhjYGFJMUpW7wy2VO2tgIuRT+k0Pil/
         Z8xl4DunemZguFsbvrpaR6CkkOsTWKs2E4CI1BJ/eCt1Gc+9V3Gnx1DjinbuDxiMSKtu
         jIpAK2249L0lTrSPnbww299ImpLVza4mram9ZI3I7sjyd0o8j+YJNWz0/nvWts+bX6VO
         Bd4Q==
X-Gm-Message-State: APjAAAU2uMWf2L+zAXZP/UCyONgFvsPoHpVAz76+Out+sKOdl6zmzjgT
	SwTfHvkrlBsXJhkrhggcHtgu7k/82UQY8z0+rJPvEO8lL9zTtRAvfr712SI9t6wLi3WTm1YEhiV
	wNbw9djUiR56pWtYQuW/mXUBt5Nu24+Lew+j7UQ3zeRZBx9pY1VnevQ2ekSewbNBijw==
X-Received: by 2002:a2e:8495:: with SMTP id b21mr34049831ljh.149.1564194575836;
        Fri, 26 Jul 2019 19:29:35 -0700 (PDT)
X-Received: by 2002:a2e:8495:: with SMTP id b21mr34049806ljh.149.1564194574815;
        Fri, 26 Jul 2019 19:29:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564194574; cv=none;
        d=google.com; s=arc-20160816;
        b=BgPaZIJMZOyPPuuERN5tW56sthIKXdhjOxEiLG/FR1o4bFDzqMhM0mPp64C2AXgBfU
         eF5re3yoAF1q34sJqVGYAQ+jOPw105ti7omzG+7sCgXD/SP+7je49k9h6rTGj28fU5Jg
         CzynoWGVzdHZJYWfigRD+SEL6Qu7mh1l0XK+enCDxlhisjSJYHhdXnsPJ09jvBHKXIE/
         zbStCc1j9EbWqrHVJAWmZNvbeuYGcwS5H2IdCqBPZ3HMBFaNmJ3xkp69JgaPl8vOMFwY
         NevTNcG/Ph2T5LHFpD2iJ2GZ4utnSOh3sktOTs9UzoMaxSwBuT4deehiVqOf3DZkdENw
         bDEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rRuVoGQyiTr9OUVJXnZ+mSEFCM9DeRijbw8KeVVr9qA=;
        b=auSBtGy7xCPlSkQ2cwhzH/lBl8imgMm0eOmaA9mGqbyv5ZlJ3PdRYzbnnIR3h0/P71
         7fOnOeTMEljVje8ziqaXnCFjmlqZn1g0S2OsKHaRqk25xsvgdRHdDDN+QvTvGZ4zh9Af
         IPKJrdW8z3wHbwTIE8IHg2R6XxvfGCdVh7cyATieynVGsID6GnP0gq1Y43D14K63RkzK
         YaRmf+SOaQLg79ZUxvHCsRG0xa/yDnY2K9QTOHDfDNPUNjvZHj4XlGzvoqurP4DAxHEt
         DnEsGbrvIn3oGvuU99bY/ZEpT7mx4zCwaRM+3/sUtVZo4qjSNNS7zKhdVaje2Qsf6DBQ
         Mzuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=CqthdUK3;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 6sor29970551ljs.44.2019.07.26.19.29.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 19:29:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=CqthdUK3;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rRuVoGQyiTr9OUVJXnZ+mSEFCM9DeRijbw8KeVVr9qA=;
        b=CqthdUK3I5f1pgMbLDofd4KnjLcPFrqkN9aDucnvupiA1OVhLJf7fiU9qJpf7ye2GT
         RbW1RNJFPP/itRtlczIUYEZnt/BZbeyMOTY+mA9Q3Br/G3SfnGCP4iMUnQIBll/n1pik
         D/0MwAQdtPTxdxt/k0w3VOygmGrY+l6w3VCNg=
X-Google-Smtp-Source: APXvYqxjDR1sojE52KoIEsFyCvKbGyP+4dMkCGofJ5I3jawUQJNtuhjyuC9lZBZd0tU+EnEqeROTIw==
X-Received: by 2002:a2e:8195:: with SMTP id e21mr48929953ljg.62.1564194574057;
        Fri, 26 Jul 2019 19:29:34 -0700 (PDT)
Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com. [209.85.167.41])
        by smtp.gmail.com with ESMTPSA id i23sm10611155ljb.7.2019.07.26.19.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 19:29:33 -0700 (PDT)
Received: by mail-lf1-f41.google.com with SMTP id c19so38351175lfm.10
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:29:32 -0700 (PDT)
X-Received: by 2002:ac2:4839:: with SMTP id 25mr46122226lft.79.1564194572710;
 Fri, 26 Jul 2019 19:29:32 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000edcb3c058e6143d5@google.com> <00000000000083ffc4058e9dddf0@google.com>
In-Reply-To: <00000000000083ffc4058e9dddf0@google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 26 Jul 2019 19:29:16 -0700
X-Gmail-Original-Message-ID: <CAHk-=why-PdP_HNbskRADMp1bnj+FwUDYpUZSYoNLNHMRPtoVA@mail.gmail.com>
Message-ID: <CAHk-=why-PdP_HNbskRADMp1bnj+FwUDYpUZSYoNLNHMRPtoVA@mail.gmail.com>
Subject: Re: memory leak in kobject_set_name_vargs (2)
To: syzbot <syzbot+ad8ca40ecd77896d51e2@syzkaller.appspotmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, David Miller <davem@davemloft.net>, 
	Dmitry Vyukov <dvyukov@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, kuznet@ms2.inr.ac.ru, 
	Kalle Valo <kvalo@codeaurora.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	luciano.coelho@intel.com, Netdev <netdev@vger.kernel.org>, 
	steffen.klassert@secunet.com, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, yoshfuji@linux-ipv6.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 4:26 PM syzbot
<syzbot+ad8ca40ecd77896d51e2@syzkaller.appspotmail.com> wrote:
>
> syzbot has bisected this bug to:
>
> commit 0e034f5c4bc408c943f9c4a06244415d75d7108c
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Wed May 18 18:51:25 2016 +0000
>
>      iwlwifi: fix mis-merge that breaks the driver

While this bisection looks more likely than the other syzbot entry
that bisected to a version change, I don't think it is correct eitger.

The bisection ended up doing a lot of "git bisect skip" because of the

    undefined reference to `nf_nat_icmp_reply_translation'

issue. Also, the memory leak doesn't seem to be entirely reliable:
when the bisect does 10 runs to verify that some test kernel is bad,
there are a couple of cases where only one or two of the ten run
failed.

Which makes me wonder if one or two of the "everything OK" runs were
actually buggy, but just happened to have all ten pass...

               Linus

