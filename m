Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFAE0C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 05:43:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90EF02073F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 05:43:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ioIki42a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90EF02073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E16A6B0003; Mon, 15 Apr 2019 01:43:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 266446B0006; Mon, 15 Apr 2019 01:43:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 108836B0007; Mon, 15 Apr 2019 01:43:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB2F6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 01:43:58 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id c18so243063lfm.14
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 22:43:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/c+Hw5+k/azU8PvnxKFqYmJEScc8yTKsIrOq90KcNSI=;
        b=a16P8EMWkaXyqatczY6EspIDc0tgdZGAaHR1NSK7Zb9zMPLoEjSyqTsYEp0ooa+7of
         3gsrnkY1uJ5D/H9PIrNllITilF+R4cmCJVI0eYbY5Bn3kvwysNRRsUVRO5twCixVJVyM
         hF2iwDgADBk8BeX9Gp0KxSQ5Cl+MZCe37h8my4k/7b8aOvLwhF75mjbeepRLmsuUzfAT
         c53Fgdiy17AJpxpzUDqgB+CHIFCiW/9V30P6g3NRnR3oU8IOKxaeKc9x00/1LAk3o1pn
         ZwiP1nCajJHaLl47TqE3JTuFclNalSmfBBvGeqVOGORcrCMDF732SM/f+JZpltqTUpFD
         w2uQ==
X-Gm-Message-State: APjAAAX4KD+JqRbvr95PY85lkK6jUasBXQKfNI1dmhmCITnuonBzDeda
	Qo4CaDqLaGiWA1VbL3Onwp6mc9HK4ZdPK6icWHdZYKyMzyfUj1xfCdjjKZs4CTHYnlCEBTsfZOQ
	2j61PapgjabDjnCuISf0rGob9jBeh/w/FcPQ5+R/nFIyJuMcIZyiVfpGCZm8H0Us2Fg==
X-Received: by 2002:a2e:1311:: with SMTP id 17mr27184563ljt.75.1555307037678;
        Sun, 14 Apr 2019 22:43:57 -0700 (PDT)
X-Received: by 2002:a2e:1311:: with SMTP id 17mr27184516ljt.75.1555307036625;
        Sun, 14 Apr 2019 22:43:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555307036; cv=none;
        d=google.com; s=arc-20160816;
        b=0GplFSLxnOq6ikBdBJg9SczwPNJ3R7RW1gmIFnHlQqyOT6tJVaOMRRL5HB921/Pix6
         XFZX5TmtjKff1sI6hPIhMd+Dsx3Rg9rAkNnIGkjAmcDpnzjsPdtn7er6/nRAoB8EuM+q
         HhZX2AovE9gbKL/NZI66Z8FaL3CRh8dd1pnqLYLghMNl0cq9G2FO0gELJ6UNCjYjf3Jc
         qNlEJvVv0sfvEXsq8SQ9ymwXFRqMbB6B9UqHTA2Hp5yhMWH4EB+zAmmXbG098AdcAKQR
         DS1NURD8W1ELjecciazUEfOpOno73jBpyqkIiwGM7oI+15IANhslJgB/eCIMYgeKPUQh
         shpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/c+Hw5+k/azU8PvnxKFqYmJEScc8yTKsIrOq90KcNSI=;
        b=W11U1w6In0JLAAWQ5lul4osjnrHHgQED3tFDnKAvYj7mdrZ3P3fZuLuBVBYAMScq+r
         OAxV+VAt6oJZWWLrnQbmOQn+FrAw6oqr/JY1E2/9lUrybUwaUZ0Zk4jWXNtbByu4FvAA
         7C3DkLaur9eGk8rwgS8QMEl45qLyy+xMlAfiqkV/Y/+NoIbHvfgM9aDqFW2dSU6K9qFc
         fKEIqj0+YJsT6a78zLlQlzJnbrTV6R/ptSivgklwWpW+hMzB+nl3RSd+W029u8hlq4as
         YW4gV01fooTXD1il9pbeTPtuinn5jxWCbMjX23Jbfjt+ThRgPUmbjbITSmxfIfPSB/Th
         hXUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ioIki42a;
       spf=pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexei.starovoitov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor12989896lfh.52.2019.04.14.22.43.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Apr 2019 22:43:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ioIki42a;
       spf=pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexei.starovoitov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/c+Hw5+k/azU8PvnxKFqYmJEScc8yTKsIrOq90KcNSI=;
        b=ioIki42aQJHfE8Z4YokPbljBrYNgoYz9Nf0Cc206GZusD6gjAIzI28wJbEZBUIKR0x
         PsSFzKpzb9INhNuwNO+nBgVpGJ1uqna8NrizyAbxNfGbUI2LkkhlraXK3tnM/qpaKrzD
         bGe8jQ9oRCQB5i+kZ/dwlOP62bXCQBJrNA021hAJJe78QJ/fwHvH9yf7NyGI5fPxBOty
         oBdQz0JqexEk5ZAzaCVCmujySd0vzIT3mi6HCeFfv9ZFsJVqV/vs7BPjstAmOy5wMd59
         wbKXEEvKPJ273T+F4phTZUAiqeRrVLAAICwnq8VmmoGODBWLXdq1ITD/CZVR5fjUsKkt
         A+oA==
X-Google-Smtp-Source: APXvYqz5KJTKzNAp0YVyNvmQJpO1OyGfuUarw6cWCWeFUfRpXA51WDRxn5UL/u/lq4P5E+TmUPismgSWGwO2+n4/ick=
X-Received: by 2002:ac2:59db:: with SMTP id x27mr32758509lfn.108.1555307036239;
 Sun, 14 Apr 2019 22:43:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190414091452.22275-1-shyam.saini@amarulasolutions.com>
In-Reply-To: <20190414091452.22275-1-shyam.saini@amarulasolutions.com>
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Sun, 14 Apr 2019 22:43:44 -0700
Message-ID: <CAADnVQKx5WrUYxr_gSc5ai=fJh2cM9e26NZL1mRPkoSVQxAd0Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] include: linux: Regularise the use of FIELD_SIZEOF macro
To: Shyam Saini <shyam.saini@amarulasolutions.com>
Cc: Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Kees Cook <keescook@chromium.org>, linux-arm-kernel@lists.infradead.org, 
	linux-mips@vger.kernel.org, intel-gvt-dev@lists.freedesktop.org, 
	intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	Network Development <netdev@vger.kernel.org>, linux-ext4@vger.kernel.org, 
	devel@lists.orangefs.org, linux-mm <linux-mm@kvack.org>, linux-sctp@vger.kernel.org, 
	bpf <bpf@vger.kernel.org>, kvm@vger.kernel.org, mayhs11saini@gmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 14, 2019 at 2:15 AM Shyam Saini
<shyam.saini@amarulasolutions.com> wrote:
>
> Currently, there are 3 different macros, namely sizeof_field, SIZEOF_FIELD
> and FIELD_SIZEOF which are used to calculate the size of a member of
> structure, so to bring uniformity in entire kernel source tree lets use
> FIELD_SIZEOF and replace all occurrences of other two macros with this.
>
> For this purpose, redefine FIELD_SIZEOF in include/linux/stddef.h and
> tools/testing/selftests/bpf/bpf_util.h and remove its defination from
> include/linux/kernel.h
>
> Signed-off-by: Shyam Saini <shyam.saini@amarulasolutions.com>
> ---
>  arch/arm64/include/asm/processor.h                 | 10 +++++-----
>  arch/mips/cavium-octeon/executive/cvmx-bootmem.c   |  2 +-
>  drivers/gpu/drm/i915/gvt/scheduler.c               |  2 +-
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c |  4 ++--
>  fs/befs/linuxvfs.c                                 |  2 +-
>  fs/ext2/super.c                                    |  2 +-
>  fs/ext4/super.c                                    |  2 +-
>  fs/freevxfs/vxfs_super.c                           |  2 +-
>  fs/orangefs/super.c                                |  2 +-
>  fs/ufs/super.c                                     |  2 +-
>  include/linux/kernel.h                             |  9 ---------
>  include/linux/slab.h                               |  2 +-
>  include/linux/stddef.h                             | 11 ++++++++++-
>  kernel/fork.c                                      |  2 +-
>  kernel/utsname.c                                   |  2 +-
>  net/caif/caif_socket.c                             |  2 +-
>  net/core/skbuff.c                                  |  2 +-
>  net/ipv4/raw.c                                     |  2 +-
>  net/ipv6/raw.c                                     |  2 +-
>  net/sctp/socket.c                                  |  4 ++--
>  tools/testing/selftests/bpf/bpf_util.h             | 11 ++++++++++-

tools/ directory is for user space pieces that don't include kernel's include.
I bet your pathes break the user space builds.

