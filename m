Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01281C169C4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:24:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB2B221473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:24:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="EP0s8Xz6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB2B221473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3702F8E000A; Tue, 29 Jan 2019 20:24:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AB4D8E0001; Tue, 29 Jan 2019 20:24:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149578E000A; Tue, 29 Jan 2019 20:24:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1AE8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 20:24:01 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id p65-v6so6396242ljb.16
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:24:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=C1a30ka/2E1kf2ru6/dwkeR/Nl3MGHYcJYJXGrgWdP8=;
        b=TB8ZMouK3fUN2Ru40BSnjjnQM3J5IlRo3wr5P3RbPV4C3c8FdGkSC7OU/T4y4tOXI6
         uQXS5EBxommgUzkOJlZASlg/MGDfLbZxezcW6hyPN+RxDFf6cHzE05l0vfeU6HRW4BRS
         VEjGYcQ73pcz2k+iDP5fW3PJ3YqaLr4QxagZYvDmKyEc9CdfdsoUYGXGZHl67Bo8bs9G
         L3Mg3VwvXNprbMns/XbfURGTRscA3tW3Zk/IJpxWqFLMkfL78Yd4b76qC0C+oPQEqJaT
         8RwOtvQ8ieHIgi9SV9KiN8hwtWGWC7uJgWYl7k/cYotdhyJLQ/gD51G5qmWZSR5+Lu0h
         +j0A==
X-Gm-Message-State: AJcUukdrB90abxzgOgQtsNUv2nQJPaOBGfsh0+Hyf5t6V3qyMRT4b0rD
	xPLykmy6vs75tqGS9g6mMwM/UjES+KgvNuIih0L011pMj+MIXCtrpSjc8xfmDVLbW+h67mV2Ko4
	Dg4pMSPdz9fkG2ylpZeNaB6CxCddq1PgpZ8D8H6JNzCD/bfhoPQRMcaKQm4jCnGg3oFDn2NX8tc
	A1DjHF0esPD7ih/eaWn0T+UOA0xsPrxNRZbp77xoLLBhX2RR+bHYEcNgEZ60J0Kk0z7BD3fr1XJ
	4H32ob6BlKxKqvEnWSEHiog70FUsdQkrw2QuucCYng5ERT7UbHEJJsiQpomtkoEvW1hNZcZN0aL
	YZ3oo/0erVwHvOy5uwlJsNKre5Sr0BHFvDBqPCriPAnS0tQ8uvS6/7OO6PDaahAg05WeHFcgz3E
	Q
X-Received: by 2002:a2e:3a04:: with SMTP id h4-v6mr24392371lja.81.1548811440829;
        Tue, 29 Jan 2019 17:24:00 -0800 (PST)
X-Received: by 2002:a2e:3a04:: with SMTP id h4-v6mr24392336lja.81.1548811439996;
        Tue, 29 Jan 2019 17:23:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548811439; cv=none;
        d=google.com; s=arc-20160816;
        b=XfcDcwqE9RvFaG8cC0hVtehvA3UR5lHQaoTeS85l63ndXsUg7uT3XbWqwyQIP0zM68
         QyUZkNlDRVEfig998uvqHZQHupbEL4lSb09fdr/3WBvTxDyolkjRKNfZwq7GzubTeHEb
         gLZ1PDaoKGJ56BNJYN6CXsO7uQhfgsRR6TWvESqYoVK1E0Zq9oHCmoJ4CAFqmfYHGLpl
         fdjOi+ceGqqP2YTLxTj52RGtyTncVQU5909xGAGZuiKhronJzoOGD+k9p2C5t7W/4i27
         ULYAZdLwIhfKIDJdMjuiYcu320Z5kDLYzvbdmYvx2OMaw2ko3vmpL7QcK5RiNJ+byEcS
         DDpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=C1a30ka/2E1kf2ru6/dwkeR/Nl3MGHYcJYJXGrgWdP8=;
        b=VGhXyk3nVz3BcDkuUC6RTmjJq0+NOKkDyV1L+GnWcX3VndEQH+0ebCL6zrkG+bjjtk
         iEQ3DGeumEVucFDYc1Xuy8s7as+YtYbT6CKXhYaUsVgIPrWs1+aT5O7RMSQ1Znxcy+Fz
         gJSJR/O9IbO6Xhw1IWCs/yf+CzQWxOFndz8xzxV3PLijomTlRQvFNc2GZ2szLHQ24oJc
         +6ssgZ9dSNgSlEBERtlquIeqKC6Xf4yZ1y+BBK7l7iRHLGGThYy5T7gUz0SWUQZVomfs
         SMgT79A0/gNOUC9POVm1Sl4eaTbL9CWFeRC7E6i3I9T4XmZr8UvXFZpxTOKpe98rbj7c
         k5ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=EP0s8Xz6;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor10803lfl.47.2019.01.29.17.23.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 17:23:59 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=EP0s8Xz6;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=C1a30ka/2E1kf2ru6/dwkeR/Nl3MGHYcJYJXGrgWdP8=;
        b=EP0s8Xz6pTGNPqX+NK3upQvp0DKb9e+zjMdv0rYXKoDJcAjiwpY1bE/HlLZW6iJ+Ix
         xlIX37n/Ju1eA79LKsBFbDXI07L8+HtJFIKKQXsoQBdENZQWivQzSSbbNnZ4LJePvh14
         HCc5jMMhc90/l/BET81RF5s94+6A9t0XlY/vo=
X-Google-Smtp-Source: ALg8bN5iB8vXtjiAhSgxW9trXbYHXV7+NVtD/5tcHCjhv6+uqPx8pssyw5zWyenhYBaW+ZPoNwtKSg==
X-Received: by 2002:a19:22c2:: with SMTP id i185mr19634713lfi.2.1548811438982;
        Tue, 29 Jan 2019 17:23:58 -0800 (PST)
Received: from mail-lj1-f182.google.com (mail-lj1-f182.google.com. [209.85.208.182])
        by smtp.gmail.com with ESMTPSA id g17sm5332lfg.78.2019.01.29.17.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 17:23:57 -0800 (PST)
Received: by mail-lj1-f182.google.com with SMTP id q2-v6so19246463lji.10
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:23:57 -0800 (PST)
X-Received: by 2002:a2e:9e16:: with SMTP id e22-v6mr22799852ljk.4.1548811437316;
 Tue, 29 Jan 2019 17:23:57 -0800 (PST)
MIME-Version: 1.0
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
 <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
 <201901300042.x0U0g6EH085874@www262.sakura.ne.jp> <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
 <CAHk-=widebSUzbugcLS2txfucxDNOGWFbWBWVseAmxrdypDBrg@mail.gmail.com>
In-Reply-To: <CAHk-=widebSUzbugcLS2txfucxDNOGWFbWBWVseAmxrdypDBrg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Jan 2019 17:23:41 -0800
X-Gmail-Original-Message-ID: <CAHk-=wg=gquY8DT6s1Qb46HkJn=hV2uHeX-dafdb8T4iZAmhdw@mail.gmail.com>
Message-ID: <CAHk-=wg=gquY8DT6s1Qb46HkJn=hV2uHeX-dafdb8T4iZAmhdw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Yang Shi <shy828301@gmail.com>, 
	Jiufei Xue <jiufei.xue@linux.alibaba.com>, Linux MM <linux-mm@kvack.org>, 
	joseph.qi@linux.alibaba.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 5:11 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Again, this is not about sleeping. But the end result is almost the
> same: we really should strive to not do vfree() in interrupt context.

Note that we currently test the wrong thing for this: we actually
check "in_interrupt()" for the deferred case, which certainly works in
practice, and protects from deadlocks (we need vmap_area_lock for the
free-area handling)

But it doesn't actually end up testing the "oops, interrupts are
disabled in process context" issue. The "might_sleep()" check _does_
check that, iirc.

Which - as mentioned - is fine because we currently don't actually do
the TLB flush synchronously, but it's worth noting again. "vfree()"
really is a *lot* different from "kfree()". It's unsafe in all kinds
of special ways, and the locking difference is just part of it.

So whatever might_sleep() has found might be a potential real issue at
some point...

              Linus

