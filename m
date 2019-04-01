Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 153D3C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:00:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F930208E4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:00:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RyrM0uOD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F930208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FA976B0005; Mon,  1 Apr 2019 12:00:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AB686B0008; Mon,  1 Apr 2019 12:00:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 073806B000A; Mon,  1 Apr 2019 12:00:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B8C6B6B0005
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 12:00:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f1so7727905pgv.12
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 09:00:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TBDsttvMLuI81vopNshQa46wmdwbpgOxTaHW80guM9w=;
        b=nbbGNaCpZ13l9PYnDvHazgdT02Vx9pRNnw9iaIVWr3c5venB3QS9MT4pPzCM08/gop
         Ms3mMHwauNaTLhDAk7824EwuhzECqiEzjCmAYebWXvYi9BmYKWf290JafQ6UklrLKuYG
         M1UR18r9DJTS7Iza+uvZRuXCkYHfHNHjz4VFTRfWzfYg+M9VmsUjz4guADSltMIBrD/H
         XkqoblllR4e5VxwJHGytcDFFr1HyXAJ3gMjxAJUf1Bw0quN0BQ77Vy6oWkIpsjxtNFMS
         d0WYdD68JS3Vgbo2Ans233mfr225RLK7dh2O1vki4hFmRGYoKCssTwY3lmTbxekaDNrw
         IvEA==
X-Gm-Message-State: APjAAAXClZJqJOH7IyjARVICfSxOBY2XzCYmfxbbwztydeAHOMv6LSPn
	jnvlDLe5c4xbiKNPZdSvW64hx2UkwQ5thTe2oWipdCufdphyxsgTKzEOEqWUVla8W+h1NDtASm1
	gf598WqwHKDbBvA+BMhFK8BbPtHNLfNFf54xvsRD7OpyNQc59ubjSx2/jlbtKL+KHyQ==
X-Received: by 2002:a62:6985:: with SMTP id e127mr28871551pfc.188.1554134435264;
        Mon, 01 Apr 2019 09:00:35 -0700 (PDT)
X-Received: by 2002:a62:6985:: with SMTP id e127mr28871458pfc.188.1554134434260;
        Mon, 01 Apr 2019 09:00:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554134434; cv=none;
        d=google.com; s=arc-20160816;
        b=JxULHFAQL/DC/DQO2Vos4/JbcdBYnyUVd1REEPbKh9sgOL2WkC0thioUF83M8ZSP7E
         Zw6buoPQ9xZVV0Xls57Vh0PWSgnIpuMgN74CIy6ox28AnFpiSIrwIN/w1wWWY/ooX7HG
         uj+BVvxnimYewH8a6gluWOR178ugXQdYvjZ0K62pNZVLrxrMSChh5Dnk9OcNh2I0k2z5
         13Xj0O90JbqfDW0QFvClgYwsHe0n7K8jdLRgG/vYbxUnPzuelFzy/ne+uZ44zlFnO4hL
         vSZNGRLJyuu/2nlcUH9dCeqUSVOC7YA6K1DL3HLD7jLsBDIloGUTVlLFLc5ezNEaGVgG
         NwIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TBDsttvMLuI81vopNshQa46wmdwbpgOxTaHW80guM9w=;
        b=GIhMzgFY2fnJ4+/HVYBR/Y+LfnXQ4ZDTo7/9bFzfeCxnHbUTHLWwtkvGcriv+K1arB
         YjCVIhCWpvaEWN+uJZstwl5c2+uyDMBm4oop/e7D6Ve9Veb2MShwhEtqOIj2nSeQBSpE
         MlxC/p1Dl0r6TqO4AvavysvhYTdcMwqJXTeJsuczVIjAKxiYf9CnWPrZ7swT+nYGah6D
         mcQ1RjqxwwkoHa+F2rZzpCg4ZpyBw2XAE4gVv5BrhwMUsq80eJL5f7j1x1k85yHNeW91
         q/cjrwNQ7OqKhRM2a1gc8o4ex3l7YT/Q489aEt/4Hg9uZ1NpuG3brnZwvnSEfH2OLxJc
         VQdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RyrM0uOD;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor11327235pgk.81.2019.04.01.09.00.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 09:00:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RyrM0uOD;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TBDsttvMLuI81vopNshQa46wmdwbpgOxTaHW80guM9w=;
        b=RyrM0uODijT7PrxBFwlVN5xYIYKqYrij9TIVfZfwoZredFbnclsC1GZhABq0SdAVB+
         aOqtQG6mWy8qWJoSyzUcr8vC33wVG0JPFewL9bm60DED8YgA9D9wHnfEn8OkNCvztvCG
         S1uJBHfQbNsySKqFQSBzbv/3jIjuy7ZQ9KymY1GhaClcbfbLdVoSXZZRvH2p738tAnXU
         iA3/SNYARxBUcf3t0FFYMxBoSUlN4QW37XX8ohY8qqynRSyADtmtRwIsORof7iarLbdG
         eeioJ1RpEaX4DSjBVVexoqJd2NxIoZq5Xb1GNUNNz+PHz/jOk08g6BQN7mIqwZbWZJgJ
         B24A==
X-Google-Smtp-Source: APXvYqzoMtC/ivNhdBiCLOEEgUBVOT8gR3Mbe2+RyeM8GLWgfElsI+0pM69zJ2FBsIFK5z1WKODAocniwZ06dXzQBcQ=
X-Received: by 2002:a63:cf0d:: with SMTP id j13mr27072424pgg.34.1554134433329;
 Mon, 01 Apr 2019 09:00:33 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <09d6b8e5c8275de85c7aba716578fbcb3cbce924.1553093421.git.andreyknvl@google.com>
 <20190322155227.GS13384@arrakis.emea.arm.com>
In-Reply-To: <20190322155227.GS13384@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 1 Apr 2019 18:00:22 +0200
Message-ID: <CAAeHK+zEtraB9WvQEbxnzOZna09cuChOH4rAUJaQWOcfTwQi4w@mail.gmail.com>
Subject: Re: [PATCH v13 13/20] bpf, arm64: untag user pointers in stack_map_get_build_id_offset
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, 
	Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>, Yishai Hadas <yishaih@mellanox.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
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

On Fri, Mar 22, 2019 at 4:52 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, Mar 20, 2019 at 03:51:27PM +0100, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > stack_map_get_build_id_offset() uses provided user pointers for vma
> > lookups, which can only by done with untagged pointers.
> >
> > Untag user pointers in this function for doing the lookup and
> > calculating the offset, but save as is in the bpf_stack_build_id
> > struct.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  kernel/bpf/stackmap.c | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> >
> > diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
> > index 950ab2f28922..bb89341d3faf 100644
> > --- a/kernel/bpf/stackmap.c
> > +++ b/kernel/bpf/stackmap.c
> > @@ -320,7 +320,9 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
> >       }
> >
> >       for (i = 0; i < trace_nr; i++) {
> > -             vma = find_vma(current->mm, ips[i]);
> > +             u64 untagged_ip = untagged_addr(ips[i]);
> > +
> > +             vma = find_vma(current->mm, untagged_ip);
> >               if (!vma || stack_map_get_build_id(vma, id_offs[i].build_id)) {
> >                       /* per entry fall back to ips */
> >                       id_offs[i].status = BPF_STACK_BUILD_ID_IP;
> > @@ -328,7 +330,7 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
> >                       memset(id_offs[i].build_id, 0, BPF_BUILD_ID_SIZE);
> >                       continue;
> >               }
> > -             id_offs[i].offset = (vma->vm_pgoff << PAGE_SHIFT) + ips[i]
> > +             id_offs[i].offset = (vma->vm_pgoff << PAGE_SHIFT) + untagged_ip
> >                       - vma->vm_start;
> >               id_offs[i].status = BPF_STACK_BUILD_ID_VALID;
> >       }
>
> Can the ips[*] here ever be tagged?

Those are instruction pointers AFAIU, so no, not within the current
ABI. I'll drop this patch. Thanks!

>
> --
> Catalin

