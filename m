Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC319C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:25:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EDF42186A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:25:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k5fGldQp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EDF42186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FE056B028C; Thu, 28 Mar 2019 17:25:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0ACD16B028E; Thu, 28 Mar 2019 17:25:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F04F76B028F; Thu, 28 Mar 2019 17:25:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0C766B028C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:25:00 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id s82so166599ybc.22
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:25:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+5hDRqCC4Yz7e19xR7ypxPfWKLZ6F+sf7ORQmgcR9Ps=;
        b=tlhFM+nx58CGlyaHyp6eY/CCfFu31hPJnwixbUhL2xt0WQCqXJAv5prtQUlEsfjSY8
         V9xmQ/eyCXMFQFZkSwwR+HbwBLryvAusmOjvhGjrv8iGA8GrU/41OQZ+0KV+rYaH38gd
         9CFw0vSs4sqUofz6Y870dNUqGYWiMBEAUbjLnmgONpzhWili3yHRtnkqy+wz7h+4vDSg
         EXC3dJsxUDutsk7TbvHlyawoAx6whF9vqCkKKVuYBCmQa9Y/Dcx7lD+HQBqDH19dhGSY
         /bGZEXZi2No3eTvQsCtyyzO/tYrmBWAaLK58V4z1n/JAimyV9MynXEcwjvTKEXWHO8ag
         xqFQ==
X-Gm-Message-State: APjAAAVMew+CaCBH2awQMVov3F0S7pkFYsJizs7BR8g4WEbHTft9DkIH
	9Uablb9LCsbC5j7ZzmJqexfETEx9Dnw+AnoCR3UBiffuUstoBlxKoD3ybdtgAmUfZutCKwElUq/
	NTmV0yIt5N4Y7ieQiyLeSvBUTR57euVinDU1itAcP5LO16z7bA8AYrpAVVX0XBEU8xg==
X-Received: by 2002:a25:4a88:: with SMTP id x130mr37759581yba.328.1553808300505;
        Thu, 28 Mar 2019 14:25:00 -0700 (PDT)
X-Received: by 2002:a25:4a88:: with SMTP id x130mr37759541yba.328.1553808299862;
        Thu, 28 Mar 2019 14:24:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553808299; cv=none;
        d=google.com; s=arc-20160816;
        b=hbws2PIsydzBQPnncdWcPBZ1eWrGQ/llwk8c8nut1QS6KZc8AEtZ3PRrJoi8cyBOTh
         VuNyuCqwgQMW8HTCj8qPDfvapG2rgyn3bLvatoCvtyW6F2R99/5UszTJmxPQj47CtKRC
         LFrxdxC18/TClqUXebTHlnBjlbk3HjESV/rYXSfqhSm9MlYmMnmn20mkRWxlPAVjubpA
         4nzhqDFV0bDg3z15o704DFYdbcMasz2sJThLdQbuluB0SNEbkTuh93c9Canrmk5tUhfd
         ToGZr+uikI0crS25C5XzpaSAQrl5YSPXyUglr8DAq3/RCP/3RARGCJQapcu/frxVwjAk
         uIvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+5hDRqCC4Yz7e19xR7ypxPfWKLZ6F+sf7ORQmgcR9Ps=;
        b=LbfR3IQlx3RDK9Ecb5YlrIrBMzE74SNPH5dMe2+3EGGEaZKqbUF9vAoPXlhQksVfE3
         WAZL61e+Yk8TG6uqmms+1wtx7KRnMpsMD0c9vkoyctsP4yLkhp9yqz3wLe5xU+QGUZ15
         KCkelAbv3KnEok4+pIsnorDEblcr1jkkrn5P108ewBaEBDflM+08MFpRIWd7iXBMty4a
         VVl1QX09EccyziJXdAT95zntGKo/DW5x8fRSaDvff9lDLWZfdqjbEp8CgUwT+DyNO3bu
         2DBkbpGeqd3dCoMoNKhazc0oGaQKJqhgWmcYticNxZ+Kwj734R0EcVDHeKZ46Ja514zR
         K11A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=k5fGldQp;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor39633ywh.4.2019.03.28.14.24.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 14:24:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=k5fGldQp;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+5hDRqCC4Yz7e19xR7ypxPfWKLZ6F+sf7ORQmgcR9Ps=;
        b=k5fGldQpVI0bwsgIZNr9pXognzOfQvw5xFDhUL7N+zK6kdMbOoGBjgvosPG29RWwLi
         lw29EFJqYdKmc6UHgxTRSvab4ooaaBXrtxJIklUQx+K36ExLyoD+O+Kc4ydeRy5T5lTI
         btB6Q51tBV5SLbomzbqjtuhO+exQ8c1ArjLZRFvyoFxh9syQSV1vnMIKA1IT3AdcWMOK
         NNqQ6gflcs2/UtDzHP2D/RQj5YcLQCvR+NB4mnPmHqXj9AYZjkRdbM+Jez2Xw3HZXn8h
         NCKI7RKUVTQ9xmN4h83TKgVt8ekc/AGflRYCC8phl2G1czt1AtwjA7pBn4PtSaqFIB4c
         4AbA==
X-Google-Smtp-Source: APXvYqwYYXQujvgO0SGJ/j2p6/WWoKZg2i6iM5EpYPfHmNXAa0l+VqisTK4JaZddN4+LHCMHdLa+l5R5TpIE7qfdepY=
X-Received: by 2002:a0d:e252:: with SMTP id l79mr36846886ywe.248.1553808299501;
 Thu, 28 Mar 2019 14:24:59 -0700 (PDT)
MIME-Version: 1.0
References: <155379543409.24796.5783716624820175068.stgit@magnolia> <155379545404.24796.5019142212767521955.stgit@magnolia>
In-Reply-To: <155379545404.24796.5019142212767521955.stgit@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 28 Mar 2019 23:24:48 +0200
Message-ID: <CAOQ4uxgTQugRFJnUXA2JcHhzmPzi=PLT4H7UrZKzQzi_eCpVeg@mail.gmail.com>
Subject: Re: [PATCH 3/3] xfs: don't allow most setxattr to immutable files
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs <linux-xfs@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ext4 <linux-ext4@vger.kernel.org>, 
	Linux Btrfs <linux-btrfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 7:51 PM Darrick J. Wong <darrick.wong@oracle.com> wrote:
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

I think if preventing modification of projid and extent size hints is what you
are after you should place the check in xfs_ioctl_setattr() and not in
xfs_ioctl_setattr_xflags().

Yes, it sounds tempting to block changes of xfs_ioc_setxflags(),
but it leads you to a trap of 2nd time chattr +i fails on -EPERM,
because chattr(1) doesn't optimize out the SETFLAGS ioctl
in the case of unmodified flags.
I think if you try to fix that, code will get ugly, so I suggest that
you let SETFLAGS slide.

Thanks,
Amir.

> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/xfs/xfs_ioctl.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
>
>
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 2bd1c5ab5008..9cf0bc0ae2bd 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -1067,6 +1067,14 @@ xfs_ioctl_setattr_xflags(
>             !capable(CAP_LINUX_IMMUTABLE))
>                 return -EPERM;
>
> +       /*
> +        * If immutable is set and we are not clearing it, we're not allowed
> +        * to change anything else in the inode.
> +        */
> +       if ((ip->i_d.di_flags & XFS_DIFLAG_IMMUTABLE) &&
> +           (fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
> +               return -EPERM;
> +
>         /* diflags2 only valid for v3 inodes. */
>         di_flags2 = xfs_flags2diflags2(ip, fa->fsx_xflags);
>         if (di_flags2 && ip->i_d.di_version < 3)
>

