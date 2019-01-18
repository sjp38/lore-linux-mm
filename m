Return-Path: <SRS0=AIe5=P2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1631C43387
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 11:20:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69F052086D
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 11:20:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="D9GmmFAg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69F052086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 047ED8E0003; Fri, 18 Jan 2019 06:20:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F37F68E0002; Fri, 18 Jan 2019 06:20:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E29408E0003; Fri, 18 Jan 2019 06:20:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8FD98E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:20:22 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id w22so5721884vsj.15
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:20:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XqF0zZgFayTmTO/6SUH1t+WrRUcv72SweIyRMBjv87g=;
        b=UQJVMz8Cmo2H9z9CdxsS7n/6lwOE7ISNlostTzzr7ddSrJniu/GjL9UYqfxrDS5/n5
         CtAG4gK2VZoMQr8OlOV1Fv01qfnO+dUSAkLF8OoBERJCcy6Z+4tzKH4H5z78IhMwSi4n
         T4qPXC+7LlyMHNUnNWp9yHe+d6DMb5Ax04aQYjwiXrs+pC6jbvrsbcd/or8PE6pI4/kD
         3XZu8Zf+zL3Ca7MKW7i97FB3dceqSwHvqs1uKbDNY0INjYNKOd5VhyjuvEEjVveQOOXu
         KZliviaKw4FHqIKaXLF468UCSoi8FTI/+O/QDBrhjR3+M+ky2hLt23MHdyB2gL8KEo8w
         Mmkw==
X-Gm-Message-State: AJcUukcR0VxkmCdlvxvwe4oeFwFqKquEgKiuHdXMGj33l3jXgU86uq0C
	eHDjLgqtdqGB84vaidRYGjdWDdErfYiACpehvdvSb1sosRVp2QWYFtqxIyN6b0PFoukky2Au2PL
	ZJhDeFscKGN/Vw5a7ptqYExAwkkTR317miDEh4koSogs9QD7PYyFGHJkydUbN7lyeADmC+q8dw3
	KvutrHVkimuXDAmlvp7weM5aPHWS5f+g+EXwvgGLs22+GVFKL/vPoN3igx2cFkRSTCxSFh3zV6q
	HclhK2OLFixjFDPTQPI5x/rTDB4GNY3EZvqybrbZZkI5nX97XwtmI3zhsYW87crHAhHFk9nEaVJ
	lLYAPEUmfMZj0eqddjZ1FIozsSoMWL2T1mog0PD0M3C0nUekqXZ8deFu4OeI0Ppd0ZHiIZOmwto
	g
X-Received: by 2002:ab0:6597:: with SMTP id v23mr7522569uam.72.1547810422507;
        Fri, 18 Jan 2019 03:20:22 -0800 (PST)
X-Received: by 2002:ab0:6597:: with SMTP id v23mr7522556uam.72.1547810421846;
        Fri, 18 Jan 2019 03:20:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547810421; cv=none;
        d=google.com; s=arc-20160816;
        b=HOI5/5R+BSzsvcGkqpnf9zXuSnBav8g/9bEhiszex4nx68Nvnk5CnBJuykIq83O3xe
         QjEg1EiQAQ4LDOCLLYzos4sp8aIf1auL/WOYzEC6gZyzycaBVBfMJ1Jg3ab1f5z8JS9e
         /jy6yAH8sbsK6WkiYcd+dY1X+4yizFnRo0xxFS7hIbdkIkEj61bqmbXaDR7sHCEJhzQl
         G35OYCBr5XJ3XtX34AxJgC0GLtjrsxyyi5OFQNmZc65Dv1YZLALDKvW4czVOoZamO3AI
         6JD4bPf9ldPBtb6TyOvYeug0wxegJABaY+r8iTix/HeQ/L/sSgLTYcF/jbbfMhzSnP2A
         D5bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XqF0zZgFayTmTO/6SUH1t+WrRUcv72SweIyRMBjv87g=;
        b=yEW4MWPNK2zLGk0zp+3XHU4C78LoDUpXsYXTarQpaydXz6aB41fqK0dfXsDcGOYD/N
         s+xjkMyaMXsid86BvasGaqOG0j4KeSBH5ANhzRCWrrz8gjDqLEv3eN/XriSgYS84mvKT
         K2BXyPqvNMgeN0UsOEAlYtkdpTvAwftYxge8JtHRM2cHA5XrdavcT6GOi3pGBCWh4SG5
         VjgebFw642+3TYF/cBN9sFcCDiKov2GSV7v5C7YoYwxvMiulg8CArY846XbxuhrZyf7p
         KCc98B8cnUY0cr4vSVGZZgSoVeApDsTcXk3MChiFp/n0O1X5X06ZPoW3wTuuiA13GrDt
         Vv+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=D9GmmFAg;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b19sor2530773uak.40.2019.01.18.03.20.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 03:20:21 -0800 (PST)
Received-SPF: pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=D9GmmFAg;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XqF0zZgFayTmTO/6SUH1t+WrRUcv72SweIyRMBjv87g=;
        b=D9GmmFAgjv+5fMxCXp5xCcl/ZSn3HHWyfLbIKnqEUoQGUzpEQtnK872HuAFMporWy8
         FtB1I6hgNbsI6BGQyRFD66Jk28nEWyr1cJ54576q1P1tfwswQYlPZtG2LDSNwAGI5c2c
         vsmRxZ4VggCqcAce4ZGUjJzE0t3BtOo6o6NUmcmENogt0PgUndm2XUv92fNkLoN8XdiF
         eMhKQ5bgmb3zns4sBO+V0DVEjyLzAeeJ/i1ymIl+iLgWy3i+SBuuwKlGZezyWUgbN7ay
         NygDllUwwt1jhMga1NQiwO733GITXacZUEs+U3vjLk9yAcGaK99uJ+qO07OWCDuVJ+r7
         ksnw==
X-Google-Smtp-Source: ALg8bN6mxLE2fuUGoFKjllqfM6KcxqbBeCmty7KewOuDUIEDxWLGW1kJw0dz41+rI27UPKQCj1yKvjE6TfH21SValXE=
X-Received: by 2002:ab0:8d9:: with SMTP id o25mr7383232uaf.127.1547810421480;
 Fri, 18 Jan 2019 03:20:21 -0800 (PST)
MIME-Version: 1.0
References: <CAOuPNLj4QzNDt0npZn2LhZTFgDNJ1CsWPw3=wvUuxnGtQW308g@mail.gmail.com>
 <bceb32be-d508-c2a4-fa81-ab8b90323d3f@codeaurora.org> <CAOuPNLiNtPFksCuZF_vL6+YuLG0i0umzQhMCyEN69h9tySn2Vw@mail.gmail.com>
 <57ff3437-47b5-fe92-d576-084ce26aa5d8@codeaurora.org>
In-Reply-To: <57ff3437-47b5-fe92-d576-084ce26aa5d8@codeaurora.org>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Fri, 18 Jan 2019 16:50:10 +0530
Message-ID:
 <CAOuPNLjjd67FnjaHbJj_auD-EWnbc+6sc+hcT_HE6fjeKhEQrw@mail.gmail.com>
Subject: Re: Need help: how to locate failure from irq_chip subsystem
To: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Cc: open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, linux-mm@kvack.org, linux-pm@vger.kernel.org, 
	kernelnewbies@kernelnewbies.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190118112010._XUtl6ochgSJuztADmEnVnlr5sbl-F4jY5UCa-rmN2I@z>

> >> Could you please tell which QCOM SoC this board is based on?
> >>
> >
> > Snapdragon 845 with kernel 4.9.x
> > I want to know from which subsystem it is triggered:drivers/soc/qcom/
> >
>
> Irqchip driver is "drivers/irqchip/irq-gic-v3.c". The kernel you are
> using is msm-4.9 I suppose or some other kernel?
>
Yes, I am using customized version of msm-4.9 kernel based on Android.
And yes the irqchip driver is: irq-gic-v3, which I can see from config.

But, what I wanted to know is, how to find out which driver module
(hopefully under: /drivers/soc/qcom/) that register with this
irq_chip, is getting triggered at the time of crash ?
So, that I can implement irq_hold function for it, which is the cause of crash.

