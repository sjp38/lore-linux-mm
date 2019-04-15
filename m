Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51248C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 07:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DFA620693
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 07:13:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JrwGDgB5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DFA620693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 904AF6B0003; Mon, 15 Apr 2019 03:13:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B6046B0006; Mon, 15 Apr 2019 03:13:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CBBF6B0007; Mon, 15 Apr 2019 03:13:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B30C6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 03:13:52 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d49so15276062qtk.8
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 00:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=j3kbi0uMsvxuG8GVHcYa0jx5Oj3tt+hVtJy5E3Znkxk=;
        b=a1e4XFowkFOoe1nshwdp2EjKIUqxEmDtD6mHzlIQugHPF4GSOpvO8M7Gxz57BlBTpl
         jOK+MRvpgXYb+LWeejXN1Tf/pAUgFXMtT7Nk6LA6c6As11cJSfTstHRQguitUMZw889f
         4uk53PFTBGOHfO58PaKwn4UEDwF5WfFIJZ6iHTl7fxb5hyRMT5C+WT/mCsx32xShuvR0
         CGr/Whki5CH6Pke66Zu5HvZJj8lyxoBu13/BBSknAL4NopIs6yaRJwqsITapNH+Y0bmF
         cqzZco2v5XNS/GqyHEyb0NurAFj9RWMD4Feoj/0M67m29y47j9V6TJU3O8OUeH5dI0yH
         8H0Q==
X-Gm-Message-State: APjAAAWHxXzN2spJ/ScayM4m4idZyyJiSd44f/vHMYLDHcAcGWQ61SJn
	Q67MPIa3nVXZoR8jmESOQfY0Q0EOUg34VqF2EsxSdv+t3Al4VLq8ULXF6V/rHMtcWsiMVJd/xih
	UD5+94ChsoMGINRDVLYE+0WkSqRRhSvc/KQG6xgpSHxDyVdCS41W6dELNjjMni1cXzg==
X-Received: by 2002:aed:3641:: with SMTP id e59mr58652550qtb.235.1555312432004;
        Mon, 15 Apr 2019 00:13:52 -0700 (PDT)
X-Received: by 2002:aed:3641:: with SMTP id e59mr58652511qtb.235.1555312431270;
        Mon, 15 Apr 2019 00:13:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555312431; cv=none;
        d=google.com; s=arc-20160816;
        b=yGuRMmiwkPWSQR3RXSaAzRDvsASFpQ5jSpzLOGn9xFFE05n+M6BkCgUvzgIXGifspE
         vpbD9ohbRANZc1n2M2R/0ui/7TJmjRMeVDW9XhTC3M81NKjsNtXhC+qva+cM5+IW3Icx
         jjHanpC/XGoJOGiQ/tJaPNWSybh/ruqHPjMmayE+2dR6IGhH9n9IRuNHTYwC6PYQXEoP
         YgPxjAEQol+I/cHElDEmeiw4zZ7NCbynmj2C4vg/AIH7FSpwIB35x+4yZe66mbkqcJ+N
         i2Wjs/SFwnyNLUpCIJNmCMnEEFCjYEYGUkiX1Yidsjg8HSLglRQ4gnwwweGNpMDCDmS0
         /gHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=j3kbi0uMsvxuG8GVHcYa0jx5Oj3tt+hVtJy5E3Znkxk=;
        b=CQU54+r+bykVbNi3L4b7dLZWEZl6OxKCKG0A8QETdEAv252ks5b9xBolw4PtbjrNpz
         lZQxvgDvd9WQEkm2A55q78MXC1Gc1sSIMNqmdPBmjOSx0YErUxWI29HOy1PeXnX7Kryh
         h5yu2/tq1NRY+zgiqdOdnfEYdCiQ1pXykmnqHHpCh/MqQJgmB/UmFvo53JMDTOD0cTBW
         HSMw/4xThBbbc5h7aOftRHeQqDSI89wKgcClZT6efm2bfr5C3NPCc/sXx3Fg8A6cT6AC
         rDRSxBLZ5x4zblofBm8l06KbDXtyYI0hHbhG3ZuD1HmwIjlFNkWemFgftzFDCoEB3EUY
         2sFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JrwGDgB5;
       spf=pass (google.com: domain of mayhs11saini@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mayhs11saini@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m184sor311601qkb.95.2019.04.15.00.13.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Apr 2019 00:13:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of mayhs11saini@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JrwGDgB5;
       spf=pass (google.com: domain of mayhs11saini@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mayhs11saini@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=j3kbi0uMsvxuG8GVHcYa0jx5Oj3tt+hVtJy5E3Znkxk=;
        b=JrwGDgB5paFkpvAjGR+HpKqcels7xSMDLHDkKHKBTJAoS/z6H9fgmh3RNxZqzc3Mbm
         QqSqZhVlA9zZVYfzKoS2GakuhjjZtcmjdzIMdIlu0qNsfmJX1jziQcZhLbENNuRRuB0U
         LHuvdr+q6ZqkE4bfgrFNqV2eswVxaVeO6uNJevx033Hh/Rd+UoimJ7G+gYtHuIeYPMWD
         X5VMK38WMr6pT61Rl5cUQWfx7lNFGQPHPF+tQM99t/6d8XLQkopXcinifQM05fzvN5bG
         Rj4dnQxCOvY7n+f5zJtyj3G9LiHzyXy1mZL7LeIKSbHI3hryRq3UU6NxFxyXvuohYpgZ
         GDPw==
X-Google-Smtp-Source: APXvYqy7BiJy6sUxQsLMNeqGjVsNKTqXYv8xm887nUujgxsP1xwvfSah5gmuWcJIRxcv3C225rHZNDuC/Qf7KE3MLFo=
X-Received: by 2002:a37:4e4d:: with SMTP id c74mr56333890qkb.230.1555312430704;
 Mon, 15 Apr 2019 00:13:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190414091452.22275-1-shyam.saini@amarulasolutions.com> <CAADnVQKx5WrUYxr_gSc5ai=fJh2cM9e26NZL1mRPkoSVQxAd0Q@mail.gmail.com>
In-Reply-To: <CAADnVQKx5WrUYxr_gSc5ai=fJh2cM9e26NZL1mRPkoSVQxAd0Q@mail.gmail.com>
From: Shyam Saini <mayhs11saini@gmail.com>
Date: Mon, 15 Apr 2019 12:43:39 +0530
Message-ID: <CAOfkYf5FZdN3v9pkcdNmyJM5O=789bKwFmFsMTp20RE=gVgwqQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] include: linux: Regularise the use of FIELD_SIZEOF macro
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Shyam Saini <shyam.saini@amarulasolutions.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, 
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org, 
	intel-gvt-dev@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, 
	dri-devel <dri-devel@lists.freedesktop.org>, 
	Network Development <netdev@vger.kernel.org>, linux-ext4@vger.kernel.org, 
	devel@lists.orangefs.org, linux-mm <linux-mm@kvack.org>, linux-sctp@vger.kernel.org, 
	bpf <bpf@vger.kernel.org>, kvm@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Apr 15, 2019 at 11:13 AM Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
>
> On Sun, Apr 14, 2019 at 2:15 AM Shyam Saini
> <shyam.saini@amarulasolutions.com> wrote:
> >
> > Currently, there are 3 different macros, namely sizeof_field, SIZEOF_FIELD
> > and FIELD_SIZEOF which are used to calculate the size of a member of
> > structure, so to bring uniformity in entire kernel source tree lets use
> > FIELD_SIZEOF and replace all occurrences of other two macros with this.
> >
> > For this purpose, redefine FIELD_SIZEOF in include/linux/stddef.h and
> > tools/testing/selftests/bpf/bpf_util.h and remove its defination from
> > include/linux/kernel.h
> >
> > Signed-off-by: Shyam Saini <shyam.saini@amarulasolutions.com>
> > ---
> >  arch/arm64/include/asm/processor.h                 | 10 +++++-----
> >  arch/mips/cavium-octeon/executive/cvmx-bootmem.c   |  2 +-
> >  drivers/gpu/drm/i915/gvt/scheduler.c               |  2 +-
> >  drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c |  4 ++--
> >  fs/befs/linuxvfs.c                                 |  2 +-
> >  fs/ext2/super.c                                    |  2 +-
> >  fs/ext4/super.c                                    |  2 +-
> >  fs/freevxfs/vxfs_super.c                           |  2 +-
> >  fs/orangefs/super.c                                |  2 +-
> >  fs/ufs/super.c                                     |  2 +-
> >  include/linux/kernel.h                             |  9 ---------
> >  include/linux/slab.h                               |  2 +-
> >  include/linux/stddef.h                             | 11 ++++++++++-
> >  kernel/fork.c                                      |  2 +-
> >  kernel/utsname.c                                   |  2 +-
> >  net/caif/caif_socket.c                             |  2 +-
> >  net/core/skbuff.c                                  |  2 +-
> >  net/ipv4/raw.c                                     |  2 +-
> >  net/ipv6/raw.c                                     |  2 +-
> >  net/sctp/socket.c                                  |  4 ++--
> >  tools/testing/selftests/bpf/bpf_util.h             | 11 ++++++++++-
>
> tools/ directory is for user space pieces that don't include kernel's include.
> I bet your pathes break the user space builds.

I think it shouldn't because I haven't included any kernel header in
tool/ files, instead
I have introduced definition of macro in tool/ , so this patch doesn't
create any dependency
on kernel headers.

Thanks a lot,
Shyam

