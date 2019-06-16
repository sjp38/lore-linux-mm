Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E12CEC31E50
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 22:18:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7093B20866
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 22:18:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="uPTQWy7A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7093B20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA7AF8E0004; Sun, 16 Jun 2019 18:18:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D589C8E0001; Sun, 16 Jun 2019 18:18:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C474C8E0004; Sun, 16 Jun 2019 18:18:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E41F8E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 18:18:15 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so4781726plt.23
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 15:18:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=79LoYOjeIpSiTfB6IQqM/mvy3VKXBgJlyzUCk4MovNU=;
        b=ck5lCa0te0yOznzYCYcfWSw865wfZXFyDlP5/9Faj7zbURW9NiRQYOHSMqZIpJrYix
         1cjIymk2F6b7QBoV7fMMqByVIeR1RvoBajgRlpuRpnD67yY+O470KgOfRcntqYrRiquL
         4L75779NZQKJw7Fruz2Z4SBCB5iX5Hzx/COAZaPU7gPZ+nFkbZu0PSc8RxvxmVgJvUX1
         WKvz+jvFMROoYLHsONQx8aUAJN6hly4fFCONnLmX0+31Ayhehs72lGnXvtkqBAah/hXY
         RHA8pt9UNk4jsili+D+/haZruZ7zm1EtuCbsM/x4M7TCFQfnWj3eXQroFWuzHlXdnHu3
         nS1g==
X-Gm-Message-State: APjAAAUUm1XL7+goNrgtAtDJFYjTfD/9/yWp1pkrHJCOu2jmYlj76xzu
	zQXs7GNQ1Kngz2VBGiQVk9RPyKwAUzTyg7UiP/midtwV1nZrujRjC5RrvhYEWfyKTUKzNPw0U3O
	O/P+y4kMjWF3f5br/blm9SopWdFTWuvos/ftJX7TGMyskx9jcrhppg38ZZglpRWoGlA==
X-Received: by 2002:a17:90a:cf0d:: with SMTP id h13mr22130834pju.63.1560723495081;
        Sun, 16 Jun 2019 15:18:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmqiBXirqZ9vQkiCCALLzM2DZ6TrLmoR2ZJJ4CYVYljqQEIIi0xwqm+FR9V55DlZBoVifC
X-Received: by 2002:a17:90a:cf0d:: with SMTP id h13mr22130798pju.63.1560723494164;
        Sun, 16 Jun 2019 15:18:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560723494; cv=none;
        d=google.com; s=arc-20160816;
        b=pRva0xVys7E0N3JV8UzhyiNiyCILO7BPuyYdGFnIgL0Ta+pfi9/+y42laPqMdW7Ije
         YUrruLqC6Bd0UtGf2E0yC5qg7stCAmOsmN61jOBJx5bFvOPKt8xp8cDBnaMXwi0dQEd3
         NmnpdHpmIkMMxlPYwmlI3y/3qINUCKL7K87+jBTJkl5tTBodsBXQARugVzeOn/LWq9CL
         tWKrkDcDyK3LMPI+Gpata52EoMJO7sCGUK3/783VwgbNh9ecat91EzEDcTYHBbqxx1tg
         3TAa8uljhzjTH0KtrtjEDJj6G/3S4BbRuKEysm/fVzzOcaUbYVcAJ/fMF9dM6HZuO7aU
         9Ytw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=79LoYOjeIpSiTfB6IQqM/mvy3VKXBgJlyzUCk4MovNU=;
        b=OukJtcaUw2Jr1TbisQlyr6LTZ151Qblkw3SmgLbeKvgRExtuuDUdKnFSfxAHgBEvbC
         xtftUsYn2upyXCpuKmsqPnPUcOtBrPOweq/swrNmouQ+U6GPGhSNB9ufCxdHS2M5pEUM
         vdAV0GQWR3pnAOv4rdnk5t8ZuXN7YfDZMwQwERXCQsZkzgAcyhiJFbm4k12bpJXudpDE
         RJ0ixcYjaCgnPxpFyawmRmqw5ei7KjXxur1JqYQi9bXrRX9ee3rlb5tYq3IUa5/TPOmb
         ARw8Mw4sdb/6ZB0Hl/62K6pOiwLwWTn0FwrF3APrYyAUJOpc81qMhPDLmW5WF9DF+cVI
         o3vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uPTQWy7A;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d8si8064949pjw.3.2019.06.16.15.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 15:18:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uPTQWy7A;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 860812146E
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 22:18:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560723493;
	bh=O1ycWhUilyVeZV1l4Vcdv51ZM55dvixJqHvFqBWW/UQ=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=uPTQWy7A2IaMi2VBKyydX6tBMS0ETwgHQLORn92D5Ob77cz9VH+Q0CCsmmQuAjDST
	 Wlrjhv1YwjNqUQj+5SQpca8XI46FMMLkmV/MP22m2HnBN6RXFL9a06Y8VMioCARb0h
	 eq9dGVqnSe0ejcfAgRvWxQLa0KPBAe617qplclt0=
Received: by mail-wm1-f49.google.com with SMTP id z23so7102355wma.4
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 15:18:13 -0700 (PDT)
X-Received: by 2002:a1c:6242:: with SMTP id w63mr17250060wmb.161.1560723492077;
 Sun, 16 Jun 2019 15:18:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net> <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Sun, 16 Jun 2019 15:18:00 -0700
X-Gmail-Original-Message-ID: <CALCETrWZ4qUW+A+YqE36ZJHqJAzxwDgq77bL99BEKQx-=JYAtA@mail.gmail.com>
Message-ID: <CALCETrWZ4qUW+A+YqE36ZJHqJAzxwDgq77bL99BEKQx-=JYAtA@mail.gmail.com>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Marius Hillenbrand <mhillenb@amazon.de>, 
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 7:21 AM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> On Wed, 12 Jun 2019, Andy Lutomirski wrote:
> > > On Jun 12, 2019, at 12:55 PM, Dave Hansen <dave.hansen@intel.com> wro=
te:
> > >
> > >> On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
> > >> This patch series proposes to introduce a region for what we call
> > >> process-local memory into the kernel's virtual address space.
> > >
> > > It might be fun to cc some x86 folks on this series.  They might have
> > > some relevant opinions. ;)
> > >
> > > A few high-level questions:
> > >
> > > Why go to all this trouble to hide guest state like registers if all =
the
> > > guest data itself is still mapped?
> > >
> > > Where's the context-switching code?  Did I just miss it?
> > >
> > > We've discussed having per-cpu page tables where a given PGD is only =
in
> > > use from one CPU at a time.  I *think* this scheme still works in suc=
h a
> > > case, it just adds one more PGD entry that would have to context-swit=
ched.
> >
> > Fair warning: Linus is on record as absolutely hating this idea. He mig=
ht
> > change his mind, but it=E2=80=99s an uphill battle.
>
> Yes I know, but as a benefit we could get rid of all the GSBASE horrors i=
n
> the entry code as we could just put the percpu space into the local PGD.
>

I have personally suggested this to Linus on a couple of occasions,
and he seemed quite skeptical.

