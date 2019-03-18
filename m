Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECB6FC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:09:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DB3020863
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:09:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oxnKC1Tg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DB3020863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C34B6B0006; Mon, 18 Mar 2019 12:09:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24AF86B0007; Mon, 18 Mar 2019 12:09:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0ECE46B0008; Mon, 18 Mar 2019 12:09:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BEA9B6B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:09:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id i13so19067170pgb.14
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:09:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4jnBV7KXAwRH/SBiWunplsgAO5XC9ZDTjIPOKm8iM+g=;
        b=cYIoykWTQ0pv4nBpf4zArAKYjltTAioXofHK9JRTVyraUHUdRDnHSX8v0vKiJRj1mi
         7kZXSZpcblPynPVq3fuXCsKWvB+qXC8SFF+MkAcQ+fxCLQ20l2Z/RKut7PoA8ThFzR9K
         ZJ7xR5qPaOYON9r4yevuA/07RKpnMt3zsJzzhogTCTm1lw4as5Fob0ZM366spZ/vNRrn
         OqRolY4b0lHdLok2S1b81/V+B7PYv8J0fSLIrWnfBKjQsPI6C0aiyklWm+3dFGIij4kE
         a0DsXWxXEM/r7xeAMiP/LdLI41iLKKqWfZzpuzROoXbm6VgQsVvhkn4kv/3q61pNs+yC
         v3zg==
X-Gm-Message-State: APjAAAXycLyCFIYAJ6L4wVfbFT11jzvbgfaZXD8odM0WRkAk/c5m7K7g
	FZ8IgmxVls40wB1E26+QxpJ1o3vUYfKo/2oaID6NuAke3JPhksWoSsp88eh6dJEvq4KomU2/slK
	IBPVw4WOkRv41Niv237kLpsoBOsNga8Jlxy3fIUsU9qn667VnOr+Elt+Mahug3A0m9Q==
X-Received: by 2002:a62:d281:: with SMTP id c123mr19657550pfg.210.1552925340409;
        Mon, 18 Mar 2019 09:09:00 -0700 (PDT)
X-Received: by 2002:a62:d281:: with SMTP id c123mr19657482pfg.210.1552925339450;
        Mon, 18 Mar 2019 09:08:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552925339; cv=none;
        d=google.com; s=arc-20160816;
        b=pwVP+g0QoEXGhw+6EBHRkLB5b/mIBsufJjXe0DQ6mQn2zyWRXhewCY9ZFZXa3FmxH+
         xht+D7w5WrmItCGlwkR0iwlS8VkKkgaBiRPjzUMXsxQnZ2mPJHDX+bczu/epFy/NTOu9
         QPULXBuFdSbus7DaWT76W2bjxcimtQEz0HgpfRlEmKQjFdBpeVvY20uF2970wzSx3P6D
         MATPiOQI97cAOkIpgBvuSrhKlY1YHFQ1jWm7+TGw2zXJkmkYfD1y+NyBni9ELdNw38eE
         rJw6+/FE+ly96jIfW7X/JlSNGeMI69hUkAUbO5jduxfvZfpEruygqaawUUvud/sFFpuF
         WKmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4jnBV7KXAwRH/SBiWunplsgAO5XC9ZDTjIPOKm8iM+g=;
        b=uR/ew0ZD+dP6zCy/TSK1k/s8nO4p+MzaaeWKqJDmS0OR8fzq15QKtO/Fwaq2OV6eal
         mOCeaux+ubnYEyzT1+fY5k7mU9XhCqmJKsmAwNVt82BJRAeTXO8rST9vkuKc95vc/vAv
         A9c5bZvBuBtK2GP1qX8IW31E5TRP+jDzjtEqpKoqWDUClb8wrcEhuCpuX0r6N48KAdSm
         uX5IIDHyHqIZYq4vej0owGFhPp5oSPJFdeB6/ks7nGbxkjgY7WQY00ieJnuuKNpAVZkF
         KWfJAHMgL/Cnr7JrCc//K/lCOYoKiXno1ZtYDp5suvFr/5axkY/yC7JHvHP9v+FSBS5H
         /DHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oxnKC1Tg;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor1561257pfn.64.2019.03.18.09.08.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 09:08:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oxnKC1Tg;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4jnBV7KXAwRH/SBiWunplsgAO5XC9ZDTjIPOKm8iM+g=;
        b=oxnKC1TgVy0AfRUFzdhntQ4TnaWjo/dHSXwb/USSzN9iByb1J8qb9RNkXwR6mHS+mw
         U0ldrfn6mRkKtGFn2Svuia32YqyzgHr8lgGpA8Ip0euwMX1zgcj9IEez46oWi1IBddSU
         gwBvQTSUaqVbn9YXiSr6jTBOA8Xv5UO8CN9pXByf2+OfL6o1mjVRgyqe5P+Xg2G+PiCf
         NrrQ0yX3K59cnkolhi014Qa1wO07CtueVQk+/0EtrVmsp+hp6aDS9QuNbVuDWXjtk1vJ
         lpuGAyImKDa6JNaKflwTKUzEOC9JqWe+LJv/B30MBc7OlHCI7rVxIEK1sErhlvMqw4PK
         B6tw==
X-Google-Smtp-Source: APXvYqz4X+86iXGnn3Nho9z6FaNxwbl9pQbIbD8Gz0QIEPwnGUaSMpR4psZ3WXMcGuMVMNFbcG/Runz5qQVKQSjPXF0=
X-Received: by 2002:a62:4299:: with SMTP id h25mr19703730pfd.165.1552925338999;
 Mon, 18 Mar 2019 09:08:58 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com> <56d3373c1c5007d776fcd5de4523f4b9da341fb6.1552679409.git.andreyknvl@google.com>
 <04c5b2de-7fde-7625-9d42-228160879ea0@gmail.com> <CAAeHK+xXLypBpF1EE73KuzQAo0E6Y=apS46wo+swo2AB6cy3YA@mail.gmail.com>
 <CAAeHK+yxcG=KBjG0A5BicBA7Zwu6LR6t=g5b-9EAPXA8_Dfm2g@mail.gmail.com> <CANn89iJfjhNcDS_eHg-OUiGui-hyRL5iWQuu_U+BW_N9iSNbeA@mail.gmail.com>
In-Reply-To: <CANn89iJfjhNcDS_eHg-OUiGui-hyRL5iWQuu_U+BW_N9iSNbeA@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 18 Mar 2019 17:08:48 +0100
Message-ID: <CAAeHK+w+koPnKP2=3yQsj5wCVY-c6+NLBnkKWQP8Q6M6pzO4dA@mail.gmail.com>
Subject: Re: [PATCH v11 08/14] net, arm64: untag user pointers in tcp_zerocopy_receive
To: Eric Dumazet <edumazet@google.com>
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

On Mon, Mar 18, 2019 at 3:45 PM Eric Dumazet <edumazet@google.com> wrote:
>
> On Mon, Mar 18, 2019 at 6:17 AM Andrey Konovalov <andreyknvl@google.com> wrote:
> >
>
> > Looking at the code, what's the point of this address != zc->address
> > check? Should I just remove it?
>
> No you must not remove it.
>
> The test detects if a u64 ->unsigned long  conversion might have truncated bits.
>
> Quite surprisingly some people still use 32bit kernels.
>
> The ABI is 64bit only, because we did not want to have yet another compat layer.
>
> struct tcp_zerocopy_receive {
>     __u64 address; /* in: address of mapping */
>     __u32 length; /* in/out: number of bytes to map/mapped */
>     __u32 recv_skip_hint; /* out: amount of bytes to skip */
> };

Ah, got it, thanks! I'll add a comment here then, otherwise this looks
confusing.

