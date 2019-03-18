Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFB9BC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:14:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7464A20857
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:14:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oBTjxWG0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7464A20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 149446B0005; Mon, 18 Mar 2019 09:14:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D2556B0006; Mon, 18 Mar 2019 09:14:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB4FB6B0007; Mon, 18 Mar 2019 09:14:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A569F6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:14:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h15so19025321pfj.22
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 06:14:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1ivs9Ld1Cr5PW6vV2Rbbcl0Dzr7SZ2d3KOy8/STfF8A=;
        b=m7Jt1SNgBAuxJMN9jvWc9rjsu7f54ehWsYmHujE2QNcKOSsNZLGECoFmhjyGP4wpzr
         oWXbQPhwN/ZdoPyjnsNo2XuJkYVyFd5CNei/hj/lHODaoPOqlfYY3BRo3uvaAevUGUFW
         Opulmf2mhPzlxe7aphZxLflDcigjfjCdA3cbCiQ2ginB28J1bELNxio1i7z6fB+ZWbSZ
         8wPi1FdRClvCDge2do69r0UGZiIGHZ3rvBMqe9ZUZ4jKlV9DUG3Ea1N7W6FFN7OlIPwA
         UXmQq+5tcn0OpY/PnJtsTNZc87x9HkuekwP2LRI/CbNlmMmIab5YaRXQCKPgWe5MXftL
         D4ig==
X-Gm-Message-State: APjAAAWsSJyQ8Y4i6lWTm3NFgCeTmTrb4PhH7TVE33onxljEdIzx3meB
	y6kId4LwpolZobfa4AkbujImYmeCkNiTXbcOqNTeH5J8bCz8oJc09RK3kA538ywT8N5R8DF611/
	RSomJytI5DdwW3tqypspyfNd9EVTJMnRdGFwqimyzLPsv+MnPMc1sscwMX8+aifIgSA==
X-Received: by 2002:a17:902:248:: with SMTP id 66mr20260534plc.286.1552914885312;
        Mon, 18 Mar 2019 06:14:45 -0700 (PDT)
X-Received: by 2002:a17:902:248:: with SMTP id 66mr20260460plc.286.1552914884451;
        Mon, 18 Mar 2019 06:14:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552914884; cv=none;
        d=google.com; s=arc-20160816;
        b=be2mBKC0hjIux5nJHWEb/AeP3AJjrWtSZ4hDZl/vsRZR6uwUpsa0Pp8J18IfHIchtx
         EKlDfWAMnhKkMairIrwL1XkkZ42xOLuexbI2ELdkMWarkJCTNkE/JZDz2yFIfVZnpw8B
         xJ1gCEVpsyrmWccTeciOX4ds9Uj3YliXR926cSTNw4c6wjj23LelOMpvZlAiNEjX03qv
         /zrH2ko8CIdwpaTvDnHpg/oTUEG+BVM9Mp4075B5baJdGkMsStoy24yHZWICw7tVrRDS
         i/JzVnk/R/xzYoLD/2lCaPDXaxrznLPcr3WtA2uzHgW4nSYCHZt6PhLV4xV6duqEuPZw
         efxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1ivs9Ld1Cr5PW6vV2Rbbcl0Dzr7SZ2d3KOy8/STfF8A=;
        b=FP/b32/CrZs3wWaRs00tgd3LFH4bIrA9/TGAa1b5tAIi/sijGcSgkLeAFsi287u8yg
         6TzkksIaqWIXaGhVCOLRH9/GY81xP8yAc//vkoD/DNbbgVYBiLahTmnwyaxkDs2ByJju
         yxYxcPFxndYhv+d1FDLYcHk3Hj2TNxvI/JuQE8WP/Cag+e3Q5efGkV5yqdN2QhxRDfQg
         /htwKlt+/cNVsyO/6ttlZBEmGiTw8XID7cKKVp2uY98t5L7kM36POIr5n9U+x66SKR09
         KJ3iBO2WQvF1C2TUBViah3GQbxWR6qrnCUgcdKHXLyhmZ10l0awlaMkxJg+8dINrIxCJ
         k1ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oBTjxWG0;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 15sor4727098pft.66.2019.03.18.06.14.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 06:14:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oBTjxWG0;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1ivs9Ld1Cr5PW6vV2Rbbcl0Dzr7SZ2d3KOy8/STfF8A=;
        b=oBTjxWG0FPo2AisxixE5yc78gPUfLiKvFgiqW/PaDdUDoiy6wl4lIVi3A/mTKnJ0Mi
         zUOLSVZxC9hW893jS8ZhWErR02LcQZuEwaUehFiokdS3EeaxD01M//0i5N97fYoJ13hs
         4G3IljxWh8BwJgGict+arC31MtC27jws/hHnyABdKhWEEiDGh7NKhLigUonEO6+KOlSL
         3USQUM4iKqMTMbn2g6Ah+RFkp4aYcCJZ4BS8w7iWOrUqVYcWexIjpGAtdd3efZdlcCUO
         p7CFeinhJ6NC8l+UdkOHPfrLASSKPleS1Ys2ekWEuevSk7fjYkyy2ScgbpNBmFCOUU6H
         I79A==
X-Google-Smtp-Source: APXvYqzzaA64U7KtW5o2Iu/H+zw+3YlvxqyrHvqmN+ESRE331EC2V1D1mVi9n99A6ltAqp+SQeSIw+RkaEm4xazCMNc=
X-Received: by 2002:a63:68c9:: with SMTP id d192mr18023180pgc.264.1552914883949;
 Mon, 18 Mar 2019 06:14:43 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com> <56d3373c1c5007d776fcd5de4523f4b9da341fb6.1552679409.git.andreyknvl@google.com>
 <04c5b2de-7fde-7625-9d42-228160879ea0@gmail.com>
In-Reply-To: <04c5b2de-7fde-7625-9d42-228160879ea0@gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 18 Mar 2019 14:14:33 +0100
Message-ID: <CAAeHK+xXLypBpF1EE73KuzQAo0E6Y=apS46wo+swo2AB6cy3YA@mail.gmail.com>
Subject: Re: [PATCH v11 08/14] net, arm64: untag user pointers in tcp_zerocopy_receive
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf@vger.kernel.org, 
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

On Fri, Mar 15, 2019 at 9:03 PM Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
>
> On 03/15/2019 12:51 PM, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
> > can only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  net/ipv4/tcp.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 6baa6dc1b13b..89db3b4fc753 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -1758,6 +1758,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
> >       int inq;
> >       int ret;
> >
> > +     address = untagged_addr(address);
> > +
> >       if (address & (PAGE_SIZE - 1) || address != zc->address)
>
> The second test will fail, if the top bits are changed in address but not in zc->address

Will fix in v12, thanks Eric!

>
> >               return -EINVAL;
> >
> >
>

