Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C52D2C282C5
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 12:12:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80BBF20861
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 12:12:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linaro.org header.i=@linaro.org header.b="H+m7GGMj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80BBF20861
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 349428E0021; Wed, 23 Jan 2019 07:12:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F9848E001A; Wed, 23 Jan 2019 07:12:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 236DF8E0021; Wed, 23 Jan 2019 07:12:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFDEB8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 07:12:38 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id c4so1569949ioh.16
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 04:12:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=7CuKdBNpc7lIzSxWikvoBf9wcEakd+B812ZHSpJjJVY=;
        b=Nj+DKOyElEsOe1poW2ZrRFbO5ssIlvibFjvLslNeruXuh2SBBiyJlFDLSnWeFH760+
         9V5r7zd+4N22itDM73FMx1OC0Yi+P4H/5MEoLSKlKLdKLu8PDqUVxb+B5x44SlUhkwgv
         KPKHSjEXOH+9gCSSpIvmZ3oZVoEz/WZ455ePZdGR3Q4aS2xNKbARvMbzOdJv6+yK5bWb
         dMAZ5XQZ2Ek5Y+58Wblxvv5Mql0IoJX6ztTFzkehTi+/UhdTYBNpHUZeP9lk7uVYNQEI
         DfRfqNNHdqdFl8mBhsqX5O6SuNyEpDli4woLvdn3EkVol+DqdlsGwmC9Qxa6GRuVxyRK
         Xiug==
X-Gm-Message-State: AJcUukcNJTBccvJt8WntcY5yZMHcXM2yWmT4+oGcNlAkwi3t1e1waiZY
	LNjf3hkPFVG6YZUHYmzIJKeWpB+QGdWNaW4v/moLAiCwHwE5HUJZzC/tLUYNtMevbNuAuKok0JS
	E6H0zjyHhabd2b41LddALehBcYHLccOSU9szDY9LyPBICbnTF9oxHBPx5c326JMYdwPdoQW73Wr
	hCG3OOid9rlFKY/3yoMgTr2VwdIHGj4ucg1PmFXnh8qT+ZENfCUO7SUXqCEFibeHXnYl9+O9rzi
	N+ZfeQR3FAfOlmlvjK3Fglyu7M7so3G7sco4BQd0GIpa3tCoNNxw6EbalVupdzr/7fmDtQ24ycn
	e0UTdoj6n2S5oM7B3fTGfF8GJXxKr+o3Vi9IfeUkn7CC6Pgh2+BxhFEXNx/ntnw2ZbO71Rm6SnV
	H
X-Received: by 2002:a5d:904b:: with SMTP id v11mr1126082ioq.0.1548245558668;
        Wed, 23 Jan 2019 04:12:38 -0800 (PST)
X-Received: by 2002:a5d:904b:: with SMTP id v11mr1126067ioq.0.1548245558192;
        Wed, 23 Jan 2019 04:12:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548245558; cv=none;
        d=google.com; s=arc-20160816;
        b=JveVyERhRatCjqBldW3oS8OY50Tj8lxTVNFL/mZm2pKVZID3SDxw8SZ9Ba2mEji8WG
         CwgixXHegTKqEIayrNtLOBA/Zpj8o5PqFHBAgQnt92cWo4bjN3m82mDzrzc2F//jiOUV
         l/BJmbvOWb5MdyOxyR5VjQxEmM3CC3gj9/67Zz2fFdN2wm82cNvMAyKgazACJ8Hzx119
         5jnzzi2Xx6ezwHwa1sYqNIHbip57DkPUcOeC+Kt/2z5m1LiOuaevHV9TcSA3ORjW/NAq
         doEIaA6ORYPddFBdHJrw8P3BE8RtU59qJK2eqqAKWqi3uOcORfMlIhaIxP0AUNsllPBK
         M0pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=7CuKdBNpc7lIzSxWikvoBf9wcEakd+B812ZHSpJjJVY=;
        b=B21fMGJcYesnG7ecwflt4GBTFmFu4dUH9Qrq5m4nkd6D/f03eGFac7rJzCDM5eahGb
         4e2jgfnySelFsdN3PCqOWvSkGVa7vqYU3Ldj8iwTySmDYVKjB+c5VKZhXMo92U5GUZ41
         wDSRIXI9dZndbmySJsuHqTozF301p0raYtIlKZZ8pJT7cAIEebZoDpopEWhlH+QtEYYc
         iUaBA3kbsaOVQuec9WHsbuLnDYAAkHjjQZmhglois7V2BEEic7fgF/iiKhwrNE+qBIql
         9rtPOzP6AjPKjAoL7H5HW1GPHDZ8dnAxI/Ug9kQcm0yGIDFwdrQMB8XyFk3J4MQvdYVS
         FEOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=H+m7GGMj;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b62sor7168900iof.34.2019.01.23.04.12.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 04:12:38 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=H+m7GGMj;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=7CuKdBNpc7lIzSxWikvoBf9wcEakd+B812ZHSpJjJVY=;
        b=H+m7GGMjF6744xT1D2UwyNiY/KMpTtbRw5bi2y+pCDduRAgSAvhW2ZIPfnH2kOOExh
         3Su0JFmxMJMowRT9N2wYUjrjYvuBsgKmxpYbizh11PtffeWo9FwZbrdMYunm9gcvYSN7
         D7CAGGUmeHybx5kZaQ1Zx2WU51V6DvtSTJ2bc=
X-Google-Smtp-Source: ALg8bN4sFH3iEczabalnBNhAFEjMavAEqGBGd/B710UVgMJuAnz9dDSdLnQkCrtIxakuPDjbIn3RSmgeu7Pdts1qkOs=
X-Received: by 2002:a5d:8410:: with SMTP id i16mr1019729ion.173.1548245557818;
 Wed, 23 Jan 2019 04:12:37 -0800 (PST)
MIME-Version: 1.0
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org>
 <20190123115829.GA31385@kroah.com> <CAG48ez2vfXkr9dozJiGmze8k49VOXfs=K7M8bv0aQsDDpzrEFQ@mail.gmail.com>
In-Reply-To: <CAG48ez2vfXkr9dozJiGmze8k49VOXfs=K7M8bv0aQsDDpzrEFQ@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 23 Jan 2019 13:12:26 +0100
Message-ID:
 <CAKv+Gu-ECKNy+nmnbsetkOg28VR1YkFgnRsu+u9mN4DC_poBwg@mail.gmail.com>
Subject: Re: [PATCH 1/3] treewide: Lift switch variables out of switches
To: Jann Horn <jannh@google.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, 
	Alexander Popov <alex.popov@linux.com>, xen-devel <xen-devel@lists.xenproject.org>, 
	dri-devel <dri-devel@lists.freedesktop.org>, intel-gfx@lists.freedesktop.org, 
	intel-wired-lan@lists.osuosl.org, 
	Network Development <netdev@vger.kernel.org>, linux-usb <linux-usb@vger.kernel.org>, 
	linux-fsdevel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, dev@openvswitch.org, 
	Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123121226.G8bp4qylDz1Z4TGD6t4flYq14Kz_89D74w2STquo7yE@z>

On Wed, 23 Jan 2019 at 13:09, Jann Horn <jannh@google.com> wrote:
>
> On Wed, Jan 23, 2019 at 1:04 PM Greg KH <gregkh@linuxfoundation.org> wrot=
e:
> > On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
> > > Variables declared in a switch statement before any case statements
> > > cannot be initialized, so move all instances out of the switches.
> > > After this, future always-initialized stack variables will work
> > > and not throw warnings like this:
> > >
> > > fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> > > fs/fcntl.c:738:13: warning: statement will never be executed [-Wswitc=
h-unreachable]
> > >    siginfo_t si;
> > >              ^~
> >
> > That's a pain, so this means we can't have any new variables in { }
> > scope except for at the top of a function?
>
> AFAICS this only applies to switch statements (because they jump to a
> case and don't execute stuff at the start of the block), not blocks
> after if/while/... .
>

I guess that means it may apply to other cases where you do a 'goto'
into the middle of a for() loop, for instance (at the first
iteration), which is also a valid pattern.

Is there any way to tag these assignments so the diagnostic disregards them=
?

