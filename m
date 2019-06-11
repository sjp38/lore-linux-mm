Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FEA9C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5013120673
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AOEMKo6Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5013120673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0D296B0005; Tue, 11 Jun 2019 08:25:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBD876B0006; Tue, 11 Jun 2019 08:25:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C84976B0007; Tue, 11 Jun 2019 08:25:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A8BD16B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:25:18 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h3so9820056iob.20
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:25:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Gq9CRd934/jSE4tc4Cy61VEetGc4bMbhcoAUH9wfjmA=;
        b=ob8sxrsEFB60frFrkH2HEdjOFOlUsfCu7ZSzNjb3IKke5HS9+kPd64IQaUxK3Abd00
         y+NK6pFaad+FX5dABBJyH4ZZ2ftwG2TjDwH6PPxGZh2lk2UsN2pa8qmZsHePEqGlJOOh
         erpFYVCXPo9OhkRiy0I2yfE2wHya2LDcFsmtAb4rbLiioV/9V6CHCgF4DJwLCGnG9+YY
         FbZafnRVOZAvpxZdctSTyqw9TMTrA8wSJeymxdC+KbpBi2WRn6e0FFRoEmNAAddudm8z
         pOraMembsqLJfRhgCh3FP662pQ+BDUlvF8+bpwtV85zGWLZT5WC07hoI9pbIEdWaLP0p
         6nhQ==
X-Gm-Message-State: APjAAAUNgjUgpt1PR/7NBsvKfrNAa1gN1l0wbMecbobom9+t+dgH4TSO
	jPEkVsPWYnJnzLNXUUurhHSSRxIsI0gheEgR3lQTMKdoMOnblukuCeWRSOZftZEm4ZaqMhECQJq
	pj2xBYVktmV3OjBqvgGA7G6YZjSPn1ZP+PuLP+asgmsLkwwjHu4x0Atq++40ANdO5Mw==
X-Received: by 2002:a24:2f93:: with SMTP id j141mr17243373itj.158.1560255918458;
        Tue, 11 Jun 2019 05:25:18 -0700 (PDT)
X-Received: by 2002:a24:2f93:: with SMTP id j141mr17243342itj.158.1560255917757;
        Tue, 11 Jun 2019 05:25:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560255917; cv=none;
        d=google.com; s=arc-20160816;
        b=diEaR2CZOO+mslnsAbOi+koDHLhttxteNYkZyKFfYO6Ceel6698WouOUSxifaKkMWZ
         iidv3arRceSN62RlEj0748U6V2HXXYSRsF2DVAAs5xNTWTvixsQe7V2fdktU/TxghwyC
         ohC3B4yAV5XfMMaEHWntz9qNXmG9wK0isJem/dOcHlvNupwJLUic0dBCPEpRXEB4tt7h
         GG4qTkkzSI3pSnNl69N/G5TDyCMOn9+Rx+6NI+kq1vAlWgJy5bs62+qvE1m4cvWPf5hP
         pl816dyQAh6v5qYVp9vCelck9iPBkFyCqa6mh+LipAIvkOd/6CsZHzz/TJ4RSPWOgZh/
         FHOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Gq9CRd934/jSE4tc4Cy61VEetGc4bMbhcoAUH9wfjmA=;
        b=KqZyPDsBecY2aPxwgY+PnWgimY9qI11Jbvn6fZpwrmP7q0qpltl1j+53zK7Sg3paYY
         yHrd20bL8PyIdRIP+WtzYAP/21WUpUY3QIFcYIZBAaGTWHWZmVcVX2+FP+XFSsmW+NYu
         FBEye9eK1ZI+yyvDWdOg4T2d77k3b9CN1Yja0O2qY6rMTSdAeWXnC8cegKxHqtxmDsPF
         j0sd3u41uUSE9fFmaH+1xZcEwO9zCADquBa31xfSQ+NG9U4GjfcAJmCRQATKqDeUGRfB
         hKRQ5hJ8CgvX0K4gACkJfAq/B/Bi49fVmyKDVtiffxVRf/oGuEXrIEiar1lBSyx2xot6
         H2Ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AOEMKo6Q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5sor6533868ioe.13.2019.06.11.05.25.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 05:25:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AOEMKo6Q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Gq9CRd934/jSE4tc4Cy61VEetGc4bMbhcoAUH9wfjmA=;
        b=AOEMKo6QupDfoibyB4JDtla+OGVyHX+uZgoNzqLSKc24MwE2lsliSJhMg8PRNqESaX
         7kWkB1yg6tR/mppSsW1SMt08NWvRix0xVWcgS/nxAm8qEmxDTagEmG0gQgFRMB8cHCCR
         oq9G6AEQ9zjyXqeTRYb93Uyka+jdz+TCmscHhubT1ZxtP61M0SZWYWf2mV+FPicJSTV8
         kpERADiNqR3SD2e9gxMa9fimczW/Od5exGRGdR6iJi8gljtz6XU8c+O9KhUr6/fdtc+1
         pHbE9YcRCiERLl2oheR8DyUTv4IjqvJHSzFGAJvfAgTPr1Pfcpy2XfomkBqyBoGOEaTU
         7uYg==
X-Google-Smtp-Source: APXvYqzjRg84fLgMD3IEc7Ck88dUNwnDYn6PxBDGvSm78jme0lIJnzjQ1xVGoygVFyNdi7KCwTGj+1fKFgJ+OLTQCwU=
X-Received: by 2002:a6b:8dcf:: with SMTP id p198mr2542052iod.46.1560255917485;
 Tue, 11 Jun 2019 05:25:17 -0700 (PDT)
MIME-Version: 1.0
References: <1560156147-12314-1-git-send-email-laoar.shao@gmail.com> <20190610141242.382cfefa2c98b618d12057fb@linux-foundation.org>
In-Reply-To: <20190610141242.382cfefa2c98b618d12057fb@linux-foundation.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 11 Jun 2019 20:24:41 +0800
Message-ID: <CALOAHbDEWBWWz5qG6xoEMu3mqOom1K895FmFrnwrwND6tWk_ow@mail.gmail.com>
Subject: Re: [PATCH] mm/vmscan: call vmpressure_prio() in kswapd reclaim path
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 5:12 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon, 10 Jun 2019 16:42:27 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
>
> > Once the reclaim scanning depth goes too deep, it always mean we are
> > under memory pressure now.
> > This behavior should be captured by vmpressure_prio(), which should run
> > every time when the vmscan's reclaiming priority (scanning depth)
> > changes.
> > It's possible the scanning depth goes deep in kswapd reclaim path,
> > so vmpressure_prio() should be called in this path.
> >
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>
> What effect does this change have upon userspace?
>
> Presumably you observed some behaviour(?) and that behaviour was
> undesirable(?) and the patch changed that behaviour to something
> else(?) and this new behaviour is better for some reason(?).
>

When there're few free memory,
the usespace can receive the critical memory pressure event earlier,
because when we try to do direct reclaim we always wakeup the kswapd first.
Currently the vmpressure work (vmpressure_work_fn) can only be
scheduled in direct reclaim path,
and with this change, the vmpressure work can be scheduled in kswapd
reclaim path.

I think receiving the critical memory pressure event earlier can give
the userspace more chance to do something to prevent random OOM.

With this change, the vmpressure work will be scheduled more frequent
than before when the system is under memory pressure.

Thanks
Yafang

