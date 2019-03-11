Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95504C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 00:22:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49AA020657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 00:22:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="XVq1ghtY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49AA020657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C83258E0003; Sun, 10 Mar 2019 20:22:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C09398E0002; Sun, 10 Mar 2019 20:22:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF7778E0003; Sun, 10 Mar 2019 20:22:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41B9B8E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 20:22:17 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 202so735960ljj.10
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 17:22:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=USal/yenJUzX8kjSBZHXwdRtQ9sO5CC+IzZC5KOfziw=;
        b=qLQfkIeQr/Ff93c6tst9A/v/peH4RK+EjgXgeBCVATd7VlYEOxDtboAlGzFLXN51p7
         UqoRVqsjwyuibXJxcZMMVvgDo8e6UvY0FeQ6wmyCk50UH8MRl7kPR6tp2RA5h7NBIbaG
         +yQfDWbu9bm6MmqTHK5vYwgO1DEkBhuPcodp2ifzKmWw6XFcWcZUT520FGjTW4dVKxlV
         xoR7EcbYpN0K8HaUUbtvLHhaUuIHY/lFp0pTnHqW67N5+PKLgrc8bpq/5OUJ3jE7c1+U
         O9lz/jzFTP53A8JSULjCPaRlTpqmLrQy4G45Y2JJIR5ZnzOjeHkj25i5AC36RmbA89eI
         2vXA==
X-Gm-Message-State: APjAAAWkeECK0ru2faRefvpIlR51xazX9c3MswZZeDNEGvy6sn0gtzKT
	PpQ9HzefRNxzdeMz02GpzMI4GJw40ZHTqBDetjtiE0SG7A224dqW8jroyJosE4sIoCWMSSXzqwJ
	cbraAv18Ykbu9wgEE0x/OeypYf2hhMF8X+EZnQ5/J7Ja0kSj/Z8jaPcWmlc4FKX+NZur8DMWkxc
	5kCwvFj9Yu1CVK50ZH25ACbmeBhjtJY9Ei+FHo+h0K/nAGF74To1FLJBhboWxNxm+b9gyETLlTv
	gW9OWBEIXregVkL6EYQYfdZjVmAPhYwDw4alw1nkeGDAWXJ4t4m6gX05nkqjRqGYhV1vTh4hUeE
	alJLKE/TYgqcU3BZutO30vM9N5oyR+MY3mTSrgiJbsTk9MbfE9caeK+pPiVPA1i8UBDp+Gyqz8p
	W
X-Received: by 2002:a19:960c:: with SMTP id y12mr268772lfd.159.1552263736362;
        Sun, 10 Mar 2019 17:22:16 -0700 (PDT)
X-Received: by 2002:a19:960c:: with SMTP id y12mr268747lfd.159.1552263735207;
        Sun, 10 Mar 2019 17:22:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552263735; cv=none;
        d=google.com; s=arc-20160816;
        b=Ju7cDkWrrMmcGo6TKrR8DYQE9VmmplcZSiWE3Rv8mNK5QfaO7Vtfqr2MpYmOf0X+CH
         A0GLGyZP1C+5DhA0qBT7Khi5gXVKsZBcy65dweXmo82f3suG7/ga0ArF8bHpygEHB58i
         ayO3onbPfJ/CwgqCk4+FCHeOUzUVpc/Ap1zt2v+FjSfDgqjqJI3zoAfhTJYx5ly+lcuJ
         SqqekbCVzljoOaaYHIOJynpYFd5/kduNxkpqOm+uRePenxH4gIfW9zj8wMfSJHQeqj/v
         cv7gOcIQIj5DmQ/elQVAyVEfc3BrQOYKlDAJqQfjaQeYPHmEnr63ru69GPcZjCPHvjeh
         q+7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=USal/yenJUzX8kjSBZHXwdRtQ9sO5CC+IzZC5KOfziw=;
        b=xRWmnRi7YBj8IY3BAy8Xp16bpi4ekXleVd0SbM/whMTLmZ3HantGQGUq6V3iMk8oOA
         E96hPA0C+lND22DWPe1S3XziSSbRgYZfVDxFD7twq9sbPomObp/MBHAUX3gF/dQ7aRha
         cFruLVtWsIA4rmHv9GilR9FFFGtq8+0OH93b0/ZGlyXDJemBYKDkiteyvMqj77OqGg0p
         MeGp0uuMKqOHeMNLKcsz8muvIN/DOSRroDo5077f5JV7JKoa2UwHKoakALNAQF21z/nK
         Y/6lDt8Ghjl+AJI9CDGjrqijQYG9MvDGh8bTgKmnwosNLljqrdoGpIUjQU1nO876vEaS
         0QAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=XVq1ghtY;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v87sor1483688lje.22.2019.03.10.17.22.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Mar 2019 17:22:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=XVq1ghtY;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=USal/yenJUzX8kjSBZHXwdRtQ9sO5CC+IzZC5KOfziw=;
        b=XVq1ghtYjN1/sHa7q+DbnpmkoIVjXWx0LKm+gjc4koF0NiUQMKEmmDQ+qtrzS8fOQz
         qRekkacO79XeJJxlCfS//OE6CsMr4WGsK1hsJarcPq7j0sOHz4lmWWdWHhRRDWAbu1hS
         FbxOim45mSwCQxidRdpb6mR8wOZh1FbYwETlc=
X-Google-Smtp-Source: APXvYqzctlmNz7WQct6+7bZ7eEwCRBOC+9oxKts7KsiE4RiCszTtIgrMUYOuTloApAmHpeDtkDC3sg==
X-Received: by 2002:a2e:7f17:: with SMTP id a23mr14679259ljd.175.1552263734077;
        Sun, 10 Mar 2019 17:22:14 -0700 (PDT)
Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com. [209.85.167.51])
        by smtp.gmail.com with ESMTPSA id n25sm851768lfe.70.2019.03.10.17.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 17:22:13 -0700 (PDT)
Received: by mail-lf1-f51.google.com with SMTP id u2so2074769lfd.4
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 17:22:12 -0700 (PDT)
X-Received: by 2002:a19:700e:: with SMTP id h14mr15547896lfc.67.1552263732321;
 Sun, 10 Mar 2019 17:22:12 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
 <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com> <CAPcyv4hafLUr2rKdLG+3SHXyWaa0d_2g8AKKZRf2mKPW+3DUSA@mail.gmail.com>
In-Reply-To: <CAPcyv4hafLUr2rKdLG+3SHXyWaa0d_2g8AKKZRf2mKPW+3DUSA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 10 Mar 2019 17:21:56 -0700
X-Gmail-Original-Message-ID: <CAHk-=wiTM93XKaFqUOR7q7133wvzNS8Kj777EZ9E8S99NbZhAA@mail.gmail.com>
Message-ID: <CAHk-=wiTM93XKaFqUOR7q7133wvzNS8Kj777EZ9E8S99NbZhAA@mail.gmail.com>
Subject: Re: [GIT PULL] device-dax for 5.1: PMEM as RAM
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, 
	"Luck, Tony" <tony.luck@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 10, 2019 at 4:54 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Unfortunately this particular b0rkage is not constrained to nvmem.
> I.e. there's nothing specific about nvmem requiring mc-safe memory
> copy, it's a cpu problem consuming any poison regardless of
> source-media-type with "rep; movs".

So why is it sold and used for the nvdimm pmem driver?

People told me it was a big deal and machines died.

You can't suddenly change the story just because you want to expose it
to user space.

You can't have it both ways. Either nvdimms have more likelihood of,
and problems with, machine checks, or it doesn't.

The end result is the same: if intel believes the kernel needs to
treat nvdimms specially, then we're sure as hell not exposing those
snowflakes to user space.

And if intel *doesn't* believe that, then we're removing the mcsafe_* functions.

There's no "oh, it's safe to show to user space, but the kernel is
magical" middle ground here that makes sense to me.

                Linus

