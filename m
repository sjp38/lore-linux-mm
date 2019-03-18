Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CA3CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 14:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3B0820850
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 14:45:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eUd7YMW/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3B0820850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C4466B0005; Mon, 18 Mar 2019 10:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3732A6B0006; Mon, 18 Mar 2019 10:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 262C56B0007; Mon, 18 Mar 2019 10:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBE356B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:45:05 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id y129so22759368ywd.1
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 07:45:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/+Gencg0JswbAigLpd/T2ItS1NnphPhR+c6rD3BwH/4=;
        b=VQSdfM4vDUj7ckc7QvJjQDbL0Ol9n0rTfxBxPWe1YGk2ATU+WU/XsTqd6F9+clvnO7
         2t8nmEBZOR8V8E2PKw727+Obgx7LXLjgWRF9jUOfjxjvgUhIoULbceHleEpZVDJWcsUd
         F/4sV2Z3y9HX2khQliQ45lllBgvrZC7OQh9Xb9brYjxR2QMxJP06U5VjFaQSAxYcq4sX
         +KNHekyA9zXCyo1Wm/+8LEixYmP4qzn115rxyWg39l1xWL9IhHpcNfaJHUAD6ZJx+0Gs
         Xj0B1O3BJYWc0XYp0Z9pke4qIn8t/raBtjj5st99kQ0wi6iCtVYSBNU65RNy3TrJ7mmY
         OPCw==
X-Gm-Message-State: APjAAAVdF9irokOivrGusIUuUmfRwN7kl4QRfg6RB6kYVCQEelHdR+O1
	oFPhCnANI900nMSLO9htZX985qnozsqP2me2iqwUl1/9N9lOKxKvxkUt2t69M3bY5K1DxpeT6Ps
	M8n+sowPtIjD6ai3JwsG+O3Nr3nhZV6gGf+p5ggq0i8IXeLGhc8JH9HynV4EwnRQQMQ==
X-Received: by 2002:a25:1341:: with SMTP id 62mr14516701ybt.402.1552920305653;
        Mon, 18 Mar 2019 07:45:05 -0700 (PDT)
X-Received: by 2002:a25:1341:: with SMTP id 62mr14516644ybt.402.1552920304923;
        Mon, 18 Mar 2019 07:45:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552920304; cv=none;
        d=google.com; s=arc-20160816;
        b=VW0oqvwEIF042ESBTw4cBKM/O8qBXvcc9o/EKm59quTlyCfikZsUiWYaBNJM0doj4i
         c+B9vjdckwGOPmijxKlpLF+OWFU3Q8xYKMz8DltJTq9rvoRB2I/9vochUmY9e2qrsa6T
         PKalABbXkBdYdnokg92UonrR+odQtVCGOA2n9dpsXg/Qb5MRbeAEs66YHhfj/t/gTwYJ
         GOS4JWxvQD8meDg/KuIF25RTAANtaBzZmKOR+aWzChpGM8sASTlVCL/GNHEZTZJCAAbU
         qkJBN5g24npUF+yx8INOVBPgStnd05+Rm22ElC8XL44xFobHKnH7Ub9PIe+H4iCv2Gcd
         GuWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/+Gencg0JswbAigLpd/T2ItS1NnphPhR+c6rD3BwH/4=;
        b=SwpwrydFETaR8GlI3IKPPdpxFXpXIOzXrbBwecmACNGsF/agL8Yo7X7adfqVvLfocT
         rHVY5nWeNgWb805kStxIRpehl88OinSjjdL9f4WXnfi0AQVhJ06Eb2MTDLQ/DorGc0Bu
         +g38gQMtigzIAOwZk4U2gUJMZTgxA7MDKTkCAjNfRWXJwfUUaWBXC/z3xhCEkPO/JMFs
         XB65OcJX+sA3K7sFe0XULP7UZT1NOkh0BF8TCQTouZDz0KrWVZiTtoiImz8+iFfxjVZT
         7QahMwZll5WwFt8VzLdEoxrDcIE/5mRMtQ6J//PHzd8M7CSmBjUU+Dv2BWIFZZ520/R7
         Cm2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="eUd7YMW/";
       spf=pass (google.com: domain of edumazet@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=edumazet@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q202sor559964ywg.190.2019.03.18.07.45.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 07:45:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of edumazet@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="eUd7YMW/";
       spf=pass (google.com: domain of edumazet@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=edumazet@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/+Gencg0JswbAigLpd/T2ItS1NnphPhR+c6rD3BwH/4=;
        b=eUd7YMW/iwbeqVYkUaaw/cUWk71SOkrkn+hXu01mjWUDyol7Y3918h8Me2N/Lmwg82
         BACBnVwkosRYGgNkB+MEv3CCkEWOrHu3xf7N5dwYHmmMELnYsQNqsOaeyK88/Ckff/ef
         kh+B6RhAXAgdrluebHSVHeJbDqxICihTurm6Izpbs8uJk/KpMx9fOP+CQm89PWz1so10
         k5Hy+rI3GiWNLVnAFbpLH1eywVv8873JwRYu/a9tdS5LPAoqYign21IdkWCo14GRLZpi
         +1s6lB6RpgPoZI0uN8BuvtNMRbB8sYv/Hh/TeFFlme7Oddb+rSFYGGHMaF7cYJURP6Fs
         tbhg==
X-Google-Smtp-Source: APXvYqy/LrBuUxgMYxjRei67FuMQP0H17hpJ7z4CK4VwoXLf7Je3qt70qo9gwTM2VSIhDx1PncSnTBxTzploGurMk0s=
X-Received: by 2002:a81:2843:: with SMTP id o64mr13821364ywo.441.1552920303807;
 Mon, 18 Mar 2019 07:45:03 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com> <56d3373c1c5007d776fcd5de4523f4b9da341fb6.1552679409.git.andreyknvl@google.com>
 <04c5b2de-7fde-7625-9d42-228160879ea0@gmail.com> <CAAeHK+xXLypBpF1EE73KuzQAo0E6Y=apS46wo+swo2AB6cy3YA@mail.gmail.com>
 <CAAeHK+yxcG=KBjG0A5BicBA7Zwu6LR6t=g5b-9EAPXA8_Dfm2g@mail.gmail.com>
In-Reply-To: <CAAeHK+yxcG=KBjG0A5BicBA7Zwu6LR6t=g5b-9EAPXA8_Dfm2g@mail.gmail.com>
From: Eric Dumazet <edumazet@google.com>
Date: Mon, 18 Mar 2019 07:44:52 -0700
Message-ID: <CANn89iJfjhNcDS_eHg-OUiGui-hyRL5iWQuu_U+BW_N9iSNbeA@mail.gmail.com>
Subject: Re: [PATCH v11 08/14] net, arm64: untag user pointers in tcp_zerocopy_receive
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, 
	Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	"David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, 
	Daniel Borkmann <daniel@iogearbox.net>, Steven Rostedt <rostedt@goodmis.org>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	Arnaldo Carvalho de Melo <acme@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 6:17 AM Andrey Konovalov <andreyknvl@google.com> wrote:
>

> Looking at the code, what's the point of this address != zc->address
> check? Should I just remove it?

No you must not remove it.

The test detects if a u64 ->unsigned long  conversion might have truncated bits.

Quite surprisingly some people still use 32bit kernels.

The ABI is 64bit only, because we did not want to have yet another compat layer.

struct tcp_zerocopy_receive {
    __u64 address; /* in: address of mapping */
    __u32 length; /* in/out: number of bytes to map/mapped */
    __u32 recv_skip_hint; /* out: amount of bytes to skip */
};

