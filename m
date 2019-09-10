Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60B29C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:05:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0278C2089F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:05:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lAi7DV+B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0278C2089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 673EF6B0003; Tue, 10 Sep 2019 03:05:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6242E6B0006; Tue, 10 Sep 2019 03:05:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 512926B0007; Tue, 10 Sep 2019 03:05:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id 30C3D6B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 03:05:07 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C7383AF9E
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:05:06 +0000 (UTC)
X-FDA: 75918124212.11.turn32_f750523feb22
X-HE-Tag: turn32_f750523feb22
X-Filterd-Recvd-Size: 3482
Received: from mail-lf1-f65.google.com (mail-lf1-f65.google.com [209.85.167.65])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:05:06 +0000 (UTC)
Received: by mail-lf1-f65.google.com with SMTP id w67so12542245lff.4
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 00:05:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=DozwmUHwj3k2SEoSTTzpSe/D0hTydvpHRMjDyd8vPuA=;
        b=lAi7DV+BNuqvg25v5XsQCJO5S8QiXZvZkSuoSs2U68BKHCzQM0o9qMWIdQqkSXCk3g
         dEh04utjhe4CEOk9udh1fJlL/L395nobKw6BYunahGbX5dUKH9U6alypvLCdFo7gJ2wM
         g9akrlRq4pGN8otw8b2NbJa1n6JVNnMdPG2JnqGhdS2nMR6an/B/ZjzEqMNk09hneAQ/
         PXhj3enJtyWalEuVEq/GQQgOetj6SfQBY+LUKP6oxeubFlSeFZpxBDxogBodwgRauln8
         y/TruqX2F/KIe1S6gxjsQ8HSOJ6Sqa8PP1hcZmoLvM2iBHXfS6+xaOs/IFIeCk2zq68p
         jxMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to;
        bh=DozwmUHwj3k2SEoSTTzpSe/D0hTydvpHRMjDyd8vPuA=;
        b=T8M2CMV8SVvPPAQ1bfhAsmIKTyiSMll35V7z6n0QRdHWwvrjD+OYk2ETPzkDR7MwLE
         91wStd9yMFAq0B3SpnNsZ2jsgNxqwjQwA/o1ZNPfCiSO6v7b1QVxfFym1UgbpxShC+vU
         dsnOB92gk/bg9H7rXwRRBK99OkKpTXKcCyQMyVc9CUFeHTW+ns9TJKEesUmXN5yuBu7Q
         Dd3/TZOCpIbt8LR1GTk09HSfdes3DaglZkvv+g/9z0SKrt40Pr2UfNIRMgsyIChIPVmP
         RlsYwqUDRnJePOeMcenMi46S1rKcNnfjqkfrD/evbpIqyAhSN50RyJWcYBIxRNVZ/U05
         ddFQ==
X-Gm-Message-State: APjAAAXxcMvYcoOyc9zbkMUZAu6VQWGYrl3U7HHmBxjDvJgaXu50019O
	Pn+XbdpCoDrr9MOTSn+byUYJ4Kz7lqXH/W+aVz0=
X-Google-Smtp-Source: APXvYqyca1SH9H5DaRx8OiIKHA6rL3hTD1AqM+2vgGminaPlWP06PPODcpw0VTaopULzgbXjfkmUz2/0N+cTcywUsIc=
X-Received: by 2002:a19:ac0c:: with SMTP id g12mr19380686lfc.128.1568099104597;
 Tue, 10 Sep 2019 00:05:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190902094540.12786-1-janne.karhunen@gmail.com> <20190909213938.GA105935@gmail.com>
In-Reply-To: <20190909213938.GA105935@gmail.com>
From: Janne Karhunen <janne.karhunen@gmail.com>
Date: Tue, 10 Sep 2019 10:04:53 +0300
Message-ID: <CAE=NcraXOhGcPHh3cPxfaNjFXtPyDdSFa9hSrUSPfpFUmsxyMA@mail.gmail.com>
Subject: Re: [PATCH 1/3] ima: keep the integrity state of open files up to date
To: Janne Karhunen <janne.karhunen@gmail.com>, linux-integrity@vger.kernel.org, 
	linux-security-module@vger.kernel.org, Mimi Zohar <zohar@linux.ibm.com>, 
	linux-mm@kvack.org, viro@zeniv.linux.org.uk, 
	Konsta Karsisto <konsta.karsisto@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.009660, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 12:39 AM Eric Biggers <ebiggers@kernel.org> wrote:
> > Core file operations (open, close, sync, msync, truncate) are
> > now allowed to update the measurement immediately. In order
> > to maintain sufficient write performance for writes, add a
> > latency tunable delayed work workqueue for computing the
> > measurements.
>
> This still doesn't make it crash-safe.  So why is it okay?

If Android is the load, this makes it crash safe 99% of the time and
that is considerably better than 0% of the time.

That said, we have now a patch draft forming up that pushes the update
to the ext4 journal. With this patch on top we should reach the
magical 100% given data=journal mount. One step at a time.


--
Janne

