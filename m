Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3849C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 18:27:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A50CF213F2
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 18:27:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="LMDKVKJk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A50CF213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C01C6B0003; Mon, 18 Mar 2019 14:27:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 147A26B0005; Mon, 18 Mar 2019 14:27:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F28DC6B0006; Mon, 18 Mar 2019 14:27:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7D446B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 14:27:29 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id a23so570697vsd.8
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 11:27:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PuCt0PzUD5fbqjENB8IuxZ3dh4ClcFnedV0Eb6S5Bu0=;
        b=ulc/PHcV0/tYj6gE09GGXAprZBiqmSVXC8vLlfuSFeZz9DeLpoheM2lmeTvn6H4UhY
         H5ttqyUu09Ck0CwESeGdnCE6TmGH1UYnDgQZ7X5PwYGzulsvTNO5rZZbp/6zn9M0ZYH+
         D5IY71TeYqd1RbGMuhfPc3v/hRzCCbuefJjRP4iZbCQY/38pPgRK+75D7hekcI6yBYWb
         /uW0600Tln2n+e3ZOiAcjirAsH0bpSZIwGKlZmxJy27byR/bJ8OfhO/edX+120wHoBv6
         Zl6vX5zK+nkuT4JlxBEbCpPwclfnSSAxeHQq9YhzuY2RihPUA7jGlYvj4FcFlsWk6dZD
         vyRA==
X-Gm-Message-State: APjAAAVZ+lKnjPDDbe0zy3Pj+CkGc5r4d83ZxO+Oh23CRQdMRp4+nbZQ
	HBz0syf6K64hHJOG9kC/Emn298zn75hfzl63nt42YDkKg8WwwD9cpUUAeAnYEHmqCO/L021QmCy
	jD2EpjBKv55+SjXinfqNVMylgjtf4cBIazbyjPHBXO9F0X2yxQZFgeApcBiNOiDPGXA==
X-Received: by 2002:a67:ef83:: with SMTP id r3mr430vsp.177.1552933649406;
        Mon, 18 Mar 2019 11:27:29 -0700 (PDT)
X-Received: by 2002:a67:ef83:: with SMTP id r3mr390vsp.177.1552933648461;
        Mon, 18 Mar 2019 11:27:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552933648; cv=none;
        d=google.com; s=arc-20160816;
        b=AexZPhkAIJdYiu8TCZKfX7WbxuoAwN2yuAT9aKx2I1WuMMKHMr8osSrpshSbeZnYtY
         AutVTTQqpGtKf6rJL4QhNM/YFUJFxE0paj66GKM73fOBjboLayZv8GeZTKCfjlHe0WoS
         0CDE4Urm+VBWvkNhakR24QZw89hd5bohQsSlLJZwUI7ZxwYNKv6thtJyGErPEd8uuBdl
         Ck/e8b8Qza7y7suWTUes6ivs/eKvp8ZGpx9ewpuMfD4MEqItZEgsn3JDVltgzqhCB+qE
         m5/ps3FJAR61dvJlFRh+7kcxVKM+n1eLxtgYbF2HvET9sRXqfpfmKLUGNHa5it2/3btq
         wcNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PuCt0PzUD5fbqjENB8IuxZ3dh4ClcFnedV0Eb6S5Bu0=;
        b=zApQjqnnddcoZJXCgkYoYWfL+SBQMGZGbZ+pZzIDEz6G/Lpnzv/AaTFNJpTijNd4d4
         +wxVa7Nh5lDboabMCnOPfEgFIzVHSLEVHceMElKcm8vSoaN1371kBZKUgB5sKItkfxlk
         jkcKP+XRSf9esnDwiC5Qc2klMn+vwOH6ahPgYN0nyhbfMOkshhvnkT421+wuTOxXlHND
         Pv1r8cFBqoAdEV7Qslp9viZwvH3FQNK5Bs71DPBfiT2uS4k2oHe9lmHjt2FsYk1GlZ9K
         erAfzBWaqadwos2HVdjHvmoZT/9Fp7Kd3Usa6WgU/CJPD+a4hwmB4SDdqjFGrLNxXBTJ
         eSkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=LMDKVKJk;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor5665504vso.3.2019.03.18.11.27.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 11:27:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=LMDKVKJk;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PuCt0PzUD5fbqjENB8IuxZ3dh4ClcFnedV0Eb6S5Bu0=;
        b=LMDKVKJkAJCEfVXUtZx8wKZPJF4T0ITB1guKXbjJsIWiI/S+O0f0QMBmDfTodm/0Z8
         5TzWTjY5DiccDr6mG6FegSzV6lLOw9cvkO2LrEMffbQtyICuuUE2RK/wjlAsasxN5jy+
         efUFUGnrapbA1y0mFC25azVdfLJCFeJf+6FDI=
X-Google-Smtp-Source: APXvYqySG5J2qDkCJP2K1rorDYBiRx7/pzwtSau9Ul6XqvbEqH43A4Q6WTa5srAvPx9CGkx+eRlkiw==
X-Received: by 2002:a67:7f07:: with SMTP id a7mr9291294vsd.196.1552933646951;
        Mon, 18 Mar 2019 11:27:26 -0700 (PDT)
Received: from mail-vs1-f45.google.com (mail-vs1-f45.google.com. [209.85.217.45])
        by smtp.gmail.com with ESMTPSA id l193sm7052672vka.19.2019.03.18.11.27.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 11:27:25 -0700 (PDT)
Received: by mail-vs1-f45.google.com with SMTP id i207so1583048vsd.10
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 11:27:25 -0700 (PDT)
X-Received: by 2002:a67:89c9:: with SMTP id l192mr9663718vsd.188.1552933645049;
 Mon, 18 Mar 2019 11:27:25 -0700 (PDT)
MIME-Version: 1.0
References: <00000000000016f7d40583d79bd9@google.com> <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
 <20190313143503.GD9108@quack2.suse.cz> <CAGXu5j+_Ao_CU8DG9nrTbx5ioDkJUFw0cGcLBMWnvNLe_eFJ4A@mail.gmail.com>
 <20190313154712.GJ9108@quack2.suse.cz>
In-Reply-To: <20190313154712.GJ9108@quack2.suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 18 Mar 2019 11:27:12 -0700
X-Gmail-Original-Message-ID: <CAGXu5jK2cOTm=Ds_NXaCFB4i1d2d0agirHKpshy8q_2KycdnJQ@mail.gmail.com>
Message-ID: <CAGXu5jK2cOTm=Ds_NXaCFB4i1d2d0agirHKpshy8q_2KycdnJQ@mail.gmail.com>
Subject: Re: WARNING: bad usercopy in fanotify_read
To: Jan Kara <jack@suse.cz>
Cc: syzbot <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com>, 
	Amir Goldstein <amir73il@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, cai@lca.pw, 
	Chris von Recklinghausen <crecklin@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 8:47 AM Jan Kara <jack@suse.cz> wrote:
>
> On Wed 13-03-19 08:35:33, Kees Cook wrote:
> > On Wed, Mar 13, 2019 at 7:35 AM Jan Kara <jack@suse.cz> wrote:
> > > On Tue 12-03-19 23:26:22, Kees Cook wrote:
> > > > On Mon, Mar 11, 2019 at 1:42 PM syzbot
> > > > <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com> wrote:
> > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17ee410b200000
> > > > > [...]
> > > > > ------------[ cut here ]------------
> > > > > Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
> > > > > from SLAB object 'fanotify_event' (offset 40, size 8)!
> > > > > [...]
> > > > >   copy_to_user include/linux/uaccess.h:151 [inline]
> > > > >   copy_fid_to_user fs/notify/fanotify/fanotify_user.c:236 [inline]
> > > > >   copy_event_to_user fs/notify/fanotify/fanotify_user.c:294 [inline]
> > > >
> > > > Looks like this is the fh/ext_fh union in struct fanotify_fid, field
> > > > "fid" in struct fanotify_event. Given that "fid" is itself in a union
> > > > against a struct path, I think instead of a whitelist using
> > > > KMEM_CACHE_USERCOPY(), this should just use a bounce buffer to avoid
> > > > leaving a whitelist open for path or ext_fh exposure.
> > >
> > > Do you mean to protect it from a situation when some other code (i.e. not
> > > copy_fid_to_user()) would be tricked into copying ext_fh containing slab
> > > pointer to userspace?
> >
> > Yes. That's the design around the usercopy hardening. The
> > "whitelisting" is either via code (with a bounce buffer, so only the
> > specific "expected" code path can copy it), with a
> > kmem_create_usercopy() range marking (generally best for areas that
> > are not unions or when bounce buffers would be too big/slow), or with
> > implicit whitelisting (via a constant copy size that cannot change at
> > run-time, like: copy_to_user(dst, src, 6)).
> >
> > In this case, since there are multiple unions in place and
> > FANOTIFY_INLINE_FH_LEN is small, it seemed best to go with a bounce
> > buffer.
>
> OK, makes sense. I'll replace tha patch using kmem_create_usercopy() in my
> tree with a variant you've suggested.

Thanks! If you're able to update the patch, it would be nice to include:

Reported-by: syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com
Fixes: a8b13aa2 ("fanotify: enable FAN_REPORT_FID init flag")

Regardless, I'll flag the fix for syzbot:

#syz fix: fanotify: Allow copying of file handle to userspace

-- 
Kees Cook

