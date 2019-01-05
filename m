Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2825BC43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:06:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3E29222C3
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:06:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="B/cv29R5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3E29222C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70DC78E0130; Sat,  5 Jan 2019 18:06:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 695558E00F9; Sat,  5 Jan 2019 18:06:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5874B8E0130; Sat,  5 Jan 2019 18:06:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE9E38E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:06:03 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id e12-v6so10576069ljb.18
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:06:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3XKfJS3aCUI5VPJ2OoPQz6I8Q3GqY3FZEmK8PJlfXZo=;
        b=X5gA5L9cgrAp5QK9rruDEvwo+YKpJztVMkLd3xAL5+cIRTnAZNgkTOKn42OxTFPG2B
         0vuJDO3lnRCgEXf/xOctUEF+8/xFH5+N3+z2YFICR71pXa62Amd1u5y3hVr0+s8ntMDc
         WS2tT4Ar3X0fWalCHxZJbb7YoveHfIyxKQLNpDSbl+yfXik6N2mVmqpN/eG2nzVC5Sfk
         zbfyBe0JD69gEvJQNWvIRcwCjn3IouJDGFvIWKmO+wcu9aM83cGeAdRYJKEZ1UCHmy+v
         hTPJZP+XFolqldtvU+XEjPujC/kcANmlHlzibZSomVpXGSJltJe64T3iclOQjaotbiPn
         8UQA==
X-Gm-Message-State: AJcUukfIaT3HWkIHMnVUyDYvUoEecqUp5/h2TGfKDU7rhAZZ/McYz1Ra
	uUMiCWSlr4kgraiApAgMWaoU5dZZXHn74ocXJk6DGiILZ75i/zge4UNWWpZW2j3nyAPJx/bpJ/N
	F+z14bfue9tQdc0lq5DWmVMbQ1J+WsRStPNVq243vkur8uS+Z/UWdyND0APoM4eVPfTe7CRu8/p
	sZ5HAnPy3P8KNWBTwVsm7NsQS3K+pfUkCY+mvJXfQ/cAVm7uJOWuBOQHoeJqsO+t1lwAU32oCz1
	fGXC2SwaGZJW1bJ3760zG4QmRnfPubKn3GWH+Wf8fbMU5NUiN/F2cpQTPI2jjSKLfGOkx9dfQMh
	lddgav5gRTjfYupcU9YAMo6pw3dgvl9h7hlgppTyE5RJxAiNadtuh13AM1gwSp34mRHzHgqehUK
	k
X-Received: by 2002:a2e:3308:: with SMTP id d8-v6mr26227045ljc.38.1546729563106;
        Sat, 05 Jan 2019 15:06:03 -0800 (PST)
X-Received: by 2002:a2e:3308:: with SMTP id d8-v6mr26227034ljc.38.1546729562055;
        Sat, 05 Jan 2019 15:06:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546729562; cv=none;
        d=google.com; s=arc-20160816;
        b=SjXnbbeD9TxBcdbX07FZ63trQV6GooB1H5sOTe12/eUI5Q/rqyKcJNcfnJ6RWfUjKJ
         MsqhmgD0KcPythcaEAQ0DnRcNsNeOoJI5hPcOWhelbTy7u3M8sfyyseFpcL023v/1y4w
         uUS01FOkBkGhshszfV538/OR72eIMqO2gQhOkRJAXHYBLKXLb6xXTTMwKPiEuaIn3aZa
         y/NeAFvyv1SCSr4ok4WV2I/BG/KwPoelGhvK6bv/i2F6a+a3H7CUcMe75yP2CxKHFxGF
         StvSHNf4i+7nj/fduOFIVxi+mUoOunY5y59imV6xpJjylIXrYhdDZhDhg57ckyhARgvD
         Cxlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3XKfJS3aCUI5VPJ2OoPQz6I8Q3GqY3FZEmK8PJlfXZo=;
        b=NP2OnZlCNEfDORkv+dZeu8OR4nkMqk7+9vLt3AvLsn9z6D9PHHgKX6lgt3tynVPnqL
         FyJ+kl18p/SSCY9X+M8PU84RKtK4cwvK2XD13w9CIv3jkVm1+Nijk0kOFwA7eCR70wxJ
         921Y1kIKHny917irgu8st47jEWhfS5NxVmLKKkBPXBMaOwGI4jOXRM8ySAPqflHK6iA6
         fOukPb8ypOGExmI68vBSXZN1WzJ5AsO5Y1WS25hZCeY18x+wdhvTNsU77ZbzBK/ey4Mh
         +kMSNUYTpurHGOz/oCoQx8w1eYsX0xPo6ZeS9tA6/2S4gSh6wEdYmPgzcjvS1E0NraRe
         HMeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="B/cv29R5";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5-v6sor34321028lja.17.2019.01.05.15.06.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 15:06:02 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="B/cv29R5";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3XKfJS3aCUI5VPJ2OoPQz6I8Q3GqY3FZEmK8PJlfXZo=;
        b=B/cv29R5CnnR4cucX2UAJjOuhWykhQuhG+v+Oo2bw14iZUUk6FsYndgTSKJpoaicZ9
         zcGzc4h+DmkLxbm9wLZ8q++rbDh/1i1GjjM8RqoPJguvj7kh22AS5Tx7b/s0D/QAEnZY
         1EePYo9mzlT65j9NUQsGsLfB0eQtm16Ik0+aE=
X-Google-Smtp-Source: ALg8bN7n6re0bpaLDE9L8e7MDgmU3t2tjULASn6QpX1jxzgrgYkXIcMiWW7nVAwVfP29iokNvCEBDg==
X-Received: by 2002:a2e:2a06:: with SMTP id q6-v6mr4226544ljq.37.1546729561262;
        Sat, 05 Jan 2019 15:06:01 -0800 (PST)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com. [209.85.167.50])
        by smtp.gmail.com with ESMTPSA id a18-v6sm12899008ljk.86.2019.01.05.15.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 15:06:00 -0800 (PST)
Received: by mail-lf1-f50.google.com with SMTP id c16so27731756lfj.8
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:05:59 -0800 (PST)
X-Received: by 2002:a19:3fcf:: with SMTP id m198mr26764036lfa.106.1546729559515;
 Sat, 05 Jan 2019 15:05:59 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
In-Reply-To: <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 15:05:43 -0800
X-Gmail-Original-Message-ID: <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
Message-ID:
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jann Horn <jannh@google.com>
Cc: Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105230543.bfi6oG6RZ0PySir_cDIysVVqR8Iew-xkBJtB-b6VyOM@z>

On Sat, Jan 5, 2019 at 2:55 PM Jann Horn <jannh@google.com> wrote:
>
> Just checking: I guess /proc/$pid/pagemap (iow, the pagemap_read()
> handler) is less problematic because it only returns data about the
> state of page tables, and doesn't query the address_space? In other
> words, it permits monitoring evictions, but non-intrusively detecting
> that something has been loaded into memory by another process is
> harder?

Yes. I think it was brought up during the original report, but to use
the pagemap for this, you'd basically need to first populate all the
pages, and then wait for pageout.

So pagemap *does* leak very similar data, but it's much harder to use
as an attack vector.

That said, I think "mincore()" is just the simple one. You *can* (and
this was also discussed on the security list) do things like

 - fault in a single page

 - the kernel will opportunistically fault in pages that it already
has available _around_ that page.

 - then use pagemap (or just _timing_ - no real kernel support needed)
to see if those pages are now mapped in your address space

so honestly, mincore is just the "big hammer" and easy way to get at
some of this data. But it's probably worth closing exactly because
it's easy. There are other ways to get at the "are these pages mapped"
information, but they are a lot more combersome to use.

Side note: maybe we could just remove the "__mincore_unmapped_range()"
thing entirely, and basically make mincore() do what pagemap does,
which is to say "are the pages mapped in this VM".

That would be nicer than my patch, simply because removing code is
always nice. And arguably it's a better semantic anyway.

                Linus

