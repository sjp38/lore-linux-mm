Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FD47C76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:56:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6E6021BE6
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:56:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="N1XbgAzT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6E6021BE6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60E356B0006; Mon, 22 Jul 2019 03:56:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BFAC6B0008; Mon, 22 Jul 2019 03:56:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AC908E0003; Mon, 22 Jul 2019 03:56:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 31F516B0006
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 03:56:31 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id h3so42685175iob.20
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:56:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8geFXXVXfHhAz5hAbzZmIPKSSa6hTGBtefRp2yOmwvY=;
        b=T7qcqiw2yEOmISgGQIj9pbH8bBPEv2TDpF1BBMUuZUXFn44JBvU2mq475kxVMvL4+K
         KuFihK6fRqREnFHlRNcU1gehIEmJzOKZmbNfsjsEoti3kpWjNC12+wqKrBJ1DQddW1PW
         Fdc3c+yQRJxwtR9H2gxjzABi1iRLa3Tyg2w2YEDHZouM2/vAl7zlD7HdSXzh3SbTboei
         Uhf7EhWJVSmpzEmEvV+deYGAGHTbrsVMN9sMwtHdCQ+qpVC13CSuaf4Jd/2v6EfqPyzy
         UcI2rO+qwPXQAwamh4T6yCrgELsRQU62bECfmmOS/g7UdNZcWOJ6GqaUPdByCA6IPu16
         FoRw==
X-Gm-Message-State: APjAAAUjTa0qv5ttrvwXG7HY3aNwXoEKelSSDsDjmhgP59DmX58N2XNx
	nMkESXW09JGmD1JhnhUzhs4lXlh5ubeYcch+YFmPBwpzdexi+eiq/mOLK/M2woMhDtusi9Ut7ga
	Bnwld+Tey8+f9ZyTTvI0f1CBnkR6x64eX0/K3ZBQSzMap6PNaySrPjH/1WfiDnpxOoQ==
X-Received: by 2002:a6b:7109:: with SMTP id q9mr58258018iog.30.1563782190848;
        Mon, 22 Jul 2019 00:56:30 -0700 (PDT)
X-Received: by 2002:a6b:7109:: with SMTP id q9mr58257991iog.30.1563782190379;
        Mon, 22 Jul 2019 00:56:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563782190; cv=none;
        d=google.com; s=arc-20160816;
        b=PCKsjaHB8tMZjzqSwG9WR26YiD2ZXject/W2Hnpbdlruh7ZeQGdnUKaAXpITd/0mA/
         gANuFxq9hU1xKE4x2k9qikZifBipkE4SkVmiX0cdnOQb9t+A3s20vuS1NhaVlWiGbEvb
         ofQLV5WgygkTLz+EY31p1lSrWGx8Z9F0DLgmNHr2FDmFtOq4HlmaOfr8Pttxo1XgZIrU
         T5D2HpzRxLNY6xWUltDpeG2OxrI8q9OUTuLD+GpSPZ+SX/wOxTBeazhbeVOsuhKLhQBN
         yvIczJntegFxIKtK2ZtP4/YCzOG/DW3FW5lY1lEZZ2005OuCnl2TbAkMKwqOHoq2IIaU
         Pvsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8geFXXVXfHhAz5hAbzZmIPKSSa6hTGBtefRp2yOmwvY=;
        b=gUSttMRX5IeqPygUmNrMVnW07jpkVWASQjPlJu8I9Gb/eAaVBUTbW9HzQLbWjK6dar
         aHJpoZ+IWxSCC+tVKu3VYG7akbU/uJ3Q6ttPrasEyJ1b0eKPLYrWvbLMuihjr2TsRbmW
         DD331+6lOfCmvNiz84693xDbOawE6O79O431TG+pqP0Wx7kkpACPCHLB544BVhYl9Rgq
         I6Skygb9ZXczCT9mxS81nNLcQaWBwzNWqhRACH3HLgsiMdq/SyfzNHcBnSkOxToxCm/7
         fZ1w48eFaK0X1O0/UWKn3jhxkZPzwkL7NjbnEF6Sc0uflqLcAbLDysZHyt9Kuw5NDJGW
         XhNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=N1XbgAzT;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r16sor26306686ioa.128.2019.07.22.00.56.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 00:56:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=N1XbgAzT;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8geFXXVXfHhAz5hAbzZmIPKSSa6hTGBtefRp2yOmwvY=;
        b=N1XbgAzTqgPrawTL/w45g/LfC7QGk+9xu7IbhImK8mVLIaECEWGm98ZGbCvqNQ0yDd
         uJuf2axzPpkPbODs60OBo8E2jExxxKOogG08w2axhkT4y9nw/XyHFxm+nmHlm5KHFTNu
         p0RgTeiPhjM0t3YG8u7zbAa8Q1brUWrA76/GRVQAmCKTcp4Ys/oSjeHLpjYzFYAztXn+
         BFS7fRUiv5HSPB2tOP1rknpXv/4Kf8b2F4URckc/2su4p+7FjM097GxEoWipIq9j/SEh
         d4rfKc/MiK4inVoOM+jJiHdAqoBMEDvg1TOk3EymBoEd4NE9aj1fw52QMwMi7tAyVspY
         Qwvw==
X-Google-Smtp-Source: APXvYqwOhVMWNrMDgv5wpZzi3eBfgLTMQr2cjl8B1jjsVSMdjdXxE2YI1CpJ4If4ifppm0SH8qms0q0UzPEnGxYgBJk=
X-Received: by 2002:a6b:6611:: with SMTP id a17mr40200646ioc.179.1563782189924;
 Mon, 22 Jul 2019 00:56:29 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
 <CABXGCsOo-4CJicvTQm4jF4iDSqM8ic+0+HEEqP+632KfCntU+w@mail.gmail.com> <878ssqbj56.fsf@yhuang-dev.intel.com>
In-Reply-To: <878ssqbj56.fsf@yhuang-dev.intel.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Mon, 22 Jul 2019 12:56:18 +0500
Message-ID: <CABXGCsOhimxC17j=jApoty-o1roRhKYoe+oiqDZ3c1s2r3QxFw@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: "Huang, Ying" <ying.huang@intel.com>
Cc: huang ying <huang.ying.caritas@gmail.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jul 2019 at 12:53, Huang, Ying <ying.huang@intel.com> wrote:
>
> Yes.  This is quite complex.  Is the transparent huge page enabled in
> your system?  You can check the output of
>
> $ cat /sys/kernel/mm/transparent_hugepage/enabled

always [madvise] never

> And, whether is the swap device you use a SSD or NVMe disk (not HDD)?

NVMe INTEL Optane 905P SSDPE21D480GAM3

--
Best Regards,
Mike Gavrilov.

