Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62E29C43444
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 07:11:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FECB20870
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 07:11:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="HGj/rnID"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FECB20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD9828E0003; Fri, 11 Jan 2019 02:11:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A61EB8E0001; Fri, 11 Jan 2019 02:11:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 903B88E0003; Fri, 11 Jan 2019 02:11:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 218798E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:11:45 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id x18-v6so3485478lji.0
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:11:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ran2Tn+WYwgFy+GtFJyFcZV6eUa7NG8NL2k0jnbBh1A=;
        b=GkhCxAfLjk+bOM8diTQPNVGAJe6TuVV//xZY8IbeqQFqXz8M0LM7cUYGyIEEEijkJV
         Vfy5blpGLtDR6rSI3a4HKIsCAjxxVz9w7ib5QvviIv4JQLlpfQNc7W+0QOvTprEjQHtu
         xteE1AAGXTyPG0vnJFnkTsJ9iWzt0m3RTxt9clfc2eX2HugvF99YRzLkM+3C8lL/cLq2
         YoSpxy0/l5YOzrxT7gm6JxHUzKRt+T+A1h9rZkyMAHLy/Am5DxMA/3/qA0TNqcRQyiL6
         5cpfoMjJ1hMYtmtScsZt1EqJdDhh+tlv+PcAYdMuPZR8/0Hxc6kF21IUl2xq7TJF5NFq
         CpaA==
X-Gm-Message-State: AJcUukcJ7lW7va4w3knmm3GrGDbbCtPOr6wnAgyRVE+rNAdq/vHdb+tN
	L9KkteZV4AzqHx41x1SYzVx7vR48EVJsATIyPdsES+Pk+faYjGckeMLveYOTXMfkTCpFcQXU/DW
	QCTku7Dqwp8APIyKkc2NTzlNNZ5s1y95S4Xde4TPNzzJgHxe6o/3KFFV+uMfH2OysgPQH/fxgPh
	x+of7K+cGfX2LvFjO0XH8nrjI5IH6lC74oLYoSsU79rxDveTlY7QMxqEaVaPl/wuHL3qHsdoytC
	UcZ171fooGlFcmNVRGI8/YBMr4djnO/pMQrVfKp/gl3FC7d0INCSRSQIenlHidt46dLaAAZteBU
	9NPqrIAiBxCyexoT8CjkUUqM3sEjUA1h+MVYQu+9f+T9SXti3AAmxyfyW3gwl1sr+Uz1ADGidxy
	u
X-Received: by 2002:a19:24c6:: with SMTP id k189mr7224019lfk.77.1547190704407;
        Thu, 10 Jan 2019 23:11:44 -0800 (PST)
X-Received: by 2002:a19:24c6:: with SMTP id k189mr7223979lfk.77.1547190703503;
        Thu, 10 Jan 2019 23:11:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547190703; cv=none;
        d=google.com; s=arc-20160816;
        b=WmF/E1hNXJceoWSkNmsbLvFYsyIXQzfT4K5huV9v9rNahFKmFEmKFYFAcZ4lK88WEc
         aDKiJ/u/jjHUlWt8yHGHgPatTQzVjZtl80YNiqen2beJHKu1zizWbacJBj1elXdwuCk0
         S6ffxnMLFWU5AI9ak4gU9XYEPxSV1zd8h6y3a3RV3JSdqhV0kButcXfuuv6cqPyVs5h8
         QB6JvRz+v7UNyj6f34OW+wfEXTZa1AxJ/0XBVPGvd3EonuC9TyP/cFyStaJO0XFVrRgs
         bfywEpetBjpErR5YeIEsllOUOae2lCNc7IfPJ6ibums4Xc27q9CsFjoZqThub2ohsXFi
         n2cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ran2Tn+WYwgFy+GtFJyFcZV6eUa7NG8NL2k0jnbBh1A=;
        b=eMyi6QOUjKSJWECLI8Gz+LEm2yxbFq0GTr3bQlF1KqVKB7HvuZIv2Xi7y4ZLNYHV9H
         YCxRYaBGcaYzPf4gYfwqclBpCQgi59U+JE3sZHjqaC6lHf/flH/wSGMdp6pTRGVDmRxr
         iKrDaP5z6BpLFcjAyhf8AUSLyJdC0u5z9kMFCKWFU7vbyV8LrXB4oTzZhWV7pUcHIN5R
         L1w2LlHGo2PnzrMLIMbeHKsnpKWovrRfbjPUydm99Sl3ALQmS8/W4RKkVSYZdwB2ZXav
         IZh81v0j1NHNmvf8R2ErluRDNiP1Slwweq9uBqelddX43j7u2M3EW2vjINxJXVxSVFsS
         uyfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="HGj/rnID";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16sor19942555lfi.3.2019.01.10.23.11.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 23:11:43 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="HGj/rnID";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ran2Tn+WYwgFy+GtFJyFcZV6eUa7NG8NL2k0jnbBh1A=;
        b=HGj/rnIDA7w/CWKwOeurlFEaqKK1al46Dss9ncxDgNiAUDZIPiSfmNpTdB8HWGfDQ4
         kODe24uzyisA3eqzkKr6meSOn6eXHpZ7y8yrZhOmS/w/6HQBmt5S8qPz140Wj61cp28G
         jSiHMmS3IietdkxIyexQ13K9ImtqvcYArprbg=
X-Google-Smtp-Source: ALg8bN70SaxiEPRuj+TJuqakN3saTws4Oc/0n1VYj1eY8RICZWQLXq7WkOk2zhLjWg0jBj3iWtgZcQ==
X-Received: by 2002:a19:c801:: with SMTP id y1mr7058558lff.53.1547190702527;
        Thu, 10 Jan 2019 23:11:42 -0800 (PST)
Received: from mail-lf1-f49.google.com (mail-lf1-f49.google.com. [209.85.167.49])
        by smtp.gmail.com with ESMTPSA id h12-v6sm15501227ljb.80.2019.01.10.23.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 23:11:40 -0800 (PST)
Received: by mail-lf1-f49.google.com with SMTP id z13so10069395lfe.11
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:11:40 -0800 (PST)
X-Received: by 2002:a19:982:: with SMTP id 124mr7044684lfj.138.1547190699923;
 Thu, 10 Jan 2019 23:11:39 -0800 (PST)
MIME-Version: 1.0
References: <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111045750.GA27333@nautica>
In-Reply-To: <20190111045750.GA27333@nautica>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 23:11:23 -0800
X-Gmail-Original-Message-ID: <CAHk-=wiqfAdmmE+pR3O5zs=xtkd6A6ShyyCwpwSZ+341L=zVYw@mail.gmail.com>
Message-ID:
 <CAHk-=wiqfAdmmE+pR3O5zs=xtkd6A6ShyyCwpwSZ+341L=zVYw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111071123.XzgGTojkzmSBqTNcWykdIpwuZW4du82nyLlzCloN4f4@z>

On Thu, Jan 10, 2019 at 8:58 PM Dominique Martinet
<asmadeus@codewreck.org> wrote:
>
> I get on average over a few queries approximately a real time of 350ms,
> 230ms and 220ms immediately after drop cache and service restart, and
> 150ms, 60ms and 60ms after a prefetch (hand-wavy average over 3 runs, I
> didn't have the patience to do proper testing).
> (In both cases, user/sys are less than 10ms; I don't see much difference
> there)

But those numbers aren't about the mincore() change. That's just from
dropping caches.

Now, what's the difference with the mincore change, and without? Is it
actually measurable?

Because that's all that matters: is the mincore change something you
can even notice? Is it a big regression?

The fact that things are slower when they are cold in the cache isn't
the issue. The issue is whether the change to mincore semantics makes
any difference to real loads.

                Linus

