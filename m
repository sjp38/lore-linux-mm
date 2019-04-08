Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A941C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 06:21:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A91720880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 06:21:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Rx88oJdv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A91720880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A6746B028A; Mon,  8 Apr 2019 02:21:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 854286B028C; Mon,  8 Apr 2019 02:21:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71E886B028D; Mon,  8 Apr 2019 02:21:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2906B028A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 02:21:00 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id g140so9859416ywb.12
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 23:21:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=V1hfycwz+T8gKzXC1mEa3ufVAa0p9RIkob73pxd6Heg=;
        b=HX0VaWR13qaPR8gvmy6rrC2dD/uDDA6//dV3Rz96XR49P3myZZIGvUXr8ylr+EV79V
         C0X//nfGGhzT1Jx0AsZKKFK8BOd9i/K+pZd40MYGx+IFGRYkuh8TXXv1qa3oGGEYpde4
         5Hga9B7phRzoOYyJt79ROafe1GILjzPCVvGVwO18HA+cBgCPaEmlxliuM6NNad+sNFL7
         dja5AC99DcyVrjeu4w0MIFP4CqlZdTq+RlD10wtHuftsExEHoAaIAJe0est/iTMFkK4t
         2a3LlSFD6pd8hZryWzJWni4EBIiX3gQhQ/HbtpAyV12C4ChNBAm+ROAANXzsEzCFjG6T
         YoYA==
X-Gm-Message-State: APjAAAUgUnpwypmx3wzrfKfyXUguEXByudaE/w5ytZA+ZQNZpCkNXV+d
	u/49YCmLHoGw1rFqbawYZLWCGPGu185oZzRDrgPZVN4kUxuv1N/nDNZ6GoRKH5mopqbIRmEVZFV
	SE4L+wLHlpvnkYUPte7e07vfRRvCMWgaqLtzGcK3C4tRrFmYsL2gZWUo7oQftWaTsSA==
X-Received: by 2002:a25:f20a:: with SMTP id i10mr23312933ybe.171.1554704459960;
        Sun, 07 Apr 2019 23:20:59 -0700 (PDT)
X-Received: by 2002:a25:f20a:: with SMTP id i10mr23312909ybe.171.1554704459416;
        Sun, 07 Apr 2019 23:20:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554704459; cv=none;
        d=google.com; s=arc-20160816;
        b=uHysqqoqGro1pYFKkiEuHX41Ed2610ziQDVY+CtTScN35xDHyvoaoNPxUPxg8gBFYt
         6m20A1ICJO13/56n6gHZ/WgJUh6KsCsogNSH+kmelH9h3rlYpHyPU4Fky4xccq/fSKH3
         JSDtZzDprHEsdZ4Nzse5sUf3cCysvp72dW+eE1tVN87fMmlpt0oUNW4uDaKTgLMMyZ3x
         G89nIhAlX0hiav3FzUGGL+wCEBXHXkQ9sBxr/bU9zg6m088dzipPgN98jD5i/HtVrHXp
         d3aI2EKyMyUcjRul1oE5HQx8rnIj3UmIGdqGi/7lSCa0I4T22/EBYP3zzY0jEq2LDRIM
         l5hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=V1hfycwz+T8gKzXC1mEa3ufVAa0p9RIkob73pxd6Heg=;
        b=Pk2Re1rzLDQke0dr7EM+8pJ7lEBkx8+7IDjSZJiwM4AhMLjjipL7tnyGURcNOCmKFs
         O4OHp+btPblInXazVNDJU4z0coEg7dk+GcHUPqIuFZx9SPip+nSkb8VIrpvivKwqB3tQ
         /jBfN20NZmb6ND/ffoXnV2VA9xdGJkooYp8ryNjai7rcUdVSq/Ehn/8OmiBRQmp6TTvb
         tgJwLYNlEBDGMyMJrZ8uiBGEHcRff9o6GPEjTVc5vnaRPnpzV1zGEUpZiHWHRFFiJBxD
         iZjBuSwJXvAjhPrF1QuTwxfkqJ9Z24P4SkWEAFmZA4CsWhC2iR2mf2o44woynGh6yVlt
         Lbcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Rx88oJdv;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n4sor14931220ybk.91.2019.04.07.23.20.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Apr 2019 23:20:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Rx88oJdv;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=V1hfycwz+T8gKzXC1mEa3ufVAa0p9RIkob73pxd6Heg=;
        b=Rx88oJdvfbYbHfcyuYhp/HIwLgUliSzUzf9wUqkfo+IG9Z0gjcB0ovemEo39/g6R2n
         8qaI4yWCYPfJoYKsvt5Uf5MVQKmswZHay9LLbBrLO2DR0vTauFX9K16ah59wQTB11CNQ
         UTsQv7oRxk7OslVY9/BvCl1MRWQHP+TsICnT3deM71isDZlLeengy3I6gcpHFLK6baHi
         3NNKjrM/PX5QZvK4V0a24M9XEerAsp/08KEIDdUxbzKtKlRMmVCE5qcPSqCsc9+bBXwt
         5GzRnOXccH+HSbmR3tAGSJSg1+oOkOzXHDH7STRQzbbMDPqH7sBi3xMWfWwbJgckEAiC
         aCRA==
X-Google-Smtp-Source: APXvYqzcGihYsVJQygsz2fv91+mltqJC2lziBlhN0kcSkp2OBWv1mBujCpf/ni6MLrdLjhPaYvcJ/pI6OO9/8E2ylPQ=
X-Received: by 2002:a25:6b06:: with SMTP id g6mr22871030ybc.214.1554704459044;
 Sun, 07 Apr 2019 23:20:59 -0700 (PDT)
MIME-Version: 1.0
References: <155466882175.633834.15261194784129614735.stgit@magnolia> <155466884962.633834.14320700092446721044.stgit@magnolia>
In-Reply-To: <155466884962.633834.14320700092446721044.stgit@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 8 Apr 2019 09:20:47 +0300
Message-ID: <CAOQ4uxj4WLX8sWbnm11Ps+rmCNTPecV-w9YUzJfKDtDs+qTx3Q@mail.gmail.com>
Subject: Re: [PATCH 4/4] xfs: don't allow most setxattr to immutable files
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-xfs <linux-xfs@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Ext4 <linux-ext4@vger.kernel.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 7, 2019 at 11:28 PM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> The chattr manpage has this to say about immutable files:
>
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
>
> However, we don't actually check the immutable flag in the setattr code,
> which means that we can update project ids and extent size hints on
> supposedly immutable files.  Therefore, reject a setattr call on an
> immutable file except for the case where we're trying to unset
> IMMUTABLE.
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Did you miss my comment on v1, or do you not think this use case
is going to hurt any application that is not a rootkit?

chattr +i foo => OK
chattr +i foo => -EPERM

Thanks,
Amir.

