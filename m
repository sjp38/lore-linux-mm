Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E5B4C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 07:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 292A4206C0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 07:20:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uoJ2oHrR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 292A4206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9FF38E0002; Wed, 13 Feb 2019 02:20:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4EFC8E0001; Wed, 13 Feb 2019 02:20:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98D2A8E0002; Wed, 13 Feb 2019 02:20:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 714D78E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 02:20:13 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id r11so905118ybm.0
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 23:20:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HPF6yD5DAHgXAIV1vACWZVe+d25mUGRVf9xdp5LPo8k=;
        b=JkK4YOgspWHezde2y/UYYfZZ45TKj8CYcYWSmmGf76YNaWmfhUdQh3hKrsmNsUIL4+
         pv76bdpzTiogq4U7s9pKXk6km+osbpfXhFJM05N29Pt7UHJn+kc4wFHcYBQj8B7zAyqz
         IaacKC5PKn5unOg8OuD8Uv/dmITxD/Pt04ZmlwkC7BK7sp4BK/SwGmlUONFWy2A2+fgC
         ItbdOARpoh4G4PW4rmGUWijNjESPcZQLRo+4kut957FLvDnF5s6Nogu80d91xfJZbkcb
         VPKlyHMOmEsS/L/7H/oqVIzf2Yk4gAdTlKC3xExQwblaqzSYHuu+jOsK/5Nf+E1SMxSN
         L+nA==
X-Gm-Message-State: AHQUAuZ+08N9wjTpIOfnhDuV/cmJYUQ3xj55l7LagZroWmSH7DGyxNeg
	o6cE5OQNpq/UIwZd2csTPkF4qs5lMEXyHQvGCGgmMRJ7YaP8FcAmJPYB7LeKP3qu9FY8xEm34Av
	Lvh3oRK+0O1STRtzD43rNCLMEudgFbLx8aSIPtObPfudybgYRL1amHcORyeOu7wTKCZ9PEelScq
	cIs/CPuHz1sXSj4G7fN8kCR9nPWOOYu5rJoFY8PiMfDGnOWozg0SFbDt9ETNBmapqP6d3hX02qp
	NNcBaZ2xTNCpLjRMILnlB+8jniUOrJSeMPdzDNRQ9wB5VgNt7VpjzoFJLT/ij3qOusU0nxkQ+b+
	cgDo2sTlA1G1Ii5EVXFX3U1FZqp/QnKu2GKPcmj6w1p5aSeXannp9MdfRRJOQWuxteXb9/bbzV2
	Y
X-Received: by 2002:a25:37cd:: with SMTP id e196mr6094881yba.169.1550042413122;
        Tue, 12 Feb 2019 23:20:13 -0800 (PST)
X-Received: by 2002:a25:37cd:: with SMTP id e196mr6094859yba.169.1550042412530;
        Tue, 12 Feb 2019 23:20:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550042412; cv=none;
        d=google.com; s=arc-20160816;
        b=RG+t4yvFvm3aPoG2fGwMoZqZdZjIW5CPLwjviF+aiyMMzZCjYLG9jzgbBcJGzJbF4j
         ZxTZHtDEnxA6yDE2E59xEBvx1zs4OM4vci3uJfk6M92f3GPueg/3vY39mVXaN4FEcJWW
         Biwnp3NzRmEKNJZnwUIfVkzrx+RW3IYFJHO019t9tw/beJeUn3JnvL+ONzJM6bO5PjfY
         yBlC5eYoLPpy/BLYXUkd525PumEWHHrLn6aXbs5WEagefrEUhXmR7DQs2W9whRDLJ6uC
         opMuzVxOYJjDY3MgnOPVRuz2HC6lpUoI0PWofoJEgQWtC3WT+zz0wFy/haQi77DAuUQI
         q5bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HPF6yD5DAHgXAIV1vACWZVe+d25mUGRVf9xdp5LPo8k=;
        b=NvauR4T6sc62jJEDLTTKGk577Mb3x0E8a6lRBBHBcNValXy5BuTxzv/Kj6gA6TZSyp
         LqcV+mRwd/XOGRZUnwssjPNJdG9fydec9XCARmJuitBpZEKmmEDkgT8SV3yay4UkIeoH
         xBptMyjNlHF57mRpx8oau2Pma1h0hPC4xnOSdIZ3u4OwCIlrVUsohXly4Ew43ZHIZYVM
         YbN7iA4dKV5Y8+brsBzSwDsuYlF9K3cyKe4YnmgrUQ9w5lpQ/AiB417u83qtarJfLAUJ
         bIA+RVxodWLu2wd/M3Dbejg1SjsFxiR8PGyxTF70GP5fBo+yx007RNQjYiz0VvBgJaOM
         uWpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uoJ2oHrR;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i3sor2110970ywf.91.2019.02.12.23.20.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 23:20:12 -0800 (PST)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uoJ2oHrR;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HPF6yD5DAHgXAIV1vACWZVe+d25mUGRVf9xdp5LPo8k=;
        b=uoJ2oHrRafAF2oawLWlkR94ApOG7ku3/Hk7q8vAm3KyB9xX++HqFxIVbIJBZ2uTg/X
         3xIStkJM1W3MdnLrLiAX4iG80Uz/0btaLWU+K6wVZseHrtIUnqBX9vWtEpyTCqoHCGPQ
         5rJedKO28I8QcHgLUUrXWZfBZuA488uG74Xm6hbZvOcAmNXHaK3OpN91EkS2LiQhTePm
         zJm9SOTKRwDDac5wE2tyKbc4vTfTCVXbJ4TTnaB3iijrlbKzU64SwXFIsshL6BJG5DsB
         7OX7AJwkQFLDTreCFdzuzNv49ZXP3+/OgA7/7jcGqTwXUUcLh5Jvhht+NkTMwHuLHx4U
         wmcA==
X-Google-Smtp-Source: AHgI3IaJMefOiPRX8qJbKpqxucMftsRQkATfIl4/rAYG5CpcV+s7zQHKVAd7geiWTdd4nQWe2SX289IwneJ7XMcCwdU=
X-Received: by 2002:a81:5509:: with SMTP id j9mr3478611ywb.409.1550042412166;
 Tue, 12 Feb 2019 23:20:12 -0800 (PST)
MIME-Version: 1.0
References: <20190212170012.GF69686@sasha-vm> <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
In-Reply-To: <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 13 Feb 2019 09:20:00 +0200
Message-ID: <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
To: Steve French <smfrench@gmail.com>, Sasha Levin <sashal@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>, 
	"Luis R. Rodriguez" <mcgrof@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 11:56 PM Steve French <smfrench@gmail.com> wrote:
>
> Makes sense - e.g. I would like to have a process to make automation
> of the xfstests for proposed patches for stable for cifs.ko easier and
> part of the process (as we already do for cifs/smb3 related checkins
> to for-next ie linux next before sending to mainline for cifs.ko).
> Each filesystem has a different set of xfstests (and perhaps other
> mechanisms) to run so might be very specific to each file system, but
> would be helpful to discuss
>

Agreed.

Perhaps it is just a matter of communicating the stable tree workflow.
I currently only see notice emails from Greg about patches being queued
for stable.

I never saw an email from you or Greg saying, the branch "stable-xxx" is
in review. Please run your tests.

I have seen reports from LTP about stable kernels, so I know it is
being run regularly and I recently saw the set of xfstests configurations
that Sasha and Luis posted.

Is there any publicly available information about which tests are being run
on stable candidate branches?

Thanks,
Amir.

