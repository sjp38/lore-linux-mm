Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92094C282DE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:35:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 519B720870
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:35:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="UM8jkNe3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 519B720870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1F836B027D; Mon,  8 Apr 2019 01:35:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA50E6B027E; Mon,  8 Apr 2019 01:35:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C96B96B027F; Mon,  8 Apr 2019 01:35:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4916B027D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 01:35:56 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m85so3589005lje.19
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 22:35:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=f+SMtvytlSiOc/cu6kg/i2uCYQdbjbuO3DZI99pciYU=;
        b=W6wiz5M/qNZkbz2u5PYLYJgBsc2v7+vE21Oz+sTbkA7GdtdpjZtvlfVJrByK0n6vhS
         pxevnId0wfDmXzjUjiZdvXJHiQ9HdQ2wmjSUarCcySg73L8YpSKiIRnNElna8FuxHZXc
         ptA2O4stq9ZPbDJK2PratlueOMdOv3ab7NQulgqjviELPypCd/NKv2iwchTNK0Es1YTv
         hIVXbIyYDTTmTBM3VrtmOaAaYn5qlGgOzoVegG6aWBsgJ9KXXKOwM9QroZqFG0HFKQID
         mTWVt/94HOexl1U4TONpRfiew9yPbPT+00PH7U3wCg1Xw3Yz4kdGo5EsaFrNfkFI+m/C
         0OJA==
X-Gm-Message-State: APjAAAX7Qo/iSzb9Xf2xAqPbwT/RuLV7VknZf7knPiVIHJUaLDIFP2ij
	jWxjNEKn6Pra+HIOMkwLzM4GtYInyJs9H+USYsNy5yI85v5NHGRdFwQfAWgefTT/XrUFwz0RzcE
	IEiagbtcY3hDm+MlXM2Slr7Vc1qdXyY70E2FV/KoZ+yjqTXs2Cau4c3NkuzZ2yP1esQ==
X-Received: by 2002:a2e:8803:: with SMTP id x3mr14348897ljh.178.1554701755560;
        Sun, 07 Apr 2019 22:35:55 -0700 (PDT)
X-Received: by 2002:a2e:8803:: with SMTP id x3mr14348850ljh.178.1554701754636;
        Sun, 07 Apr 2019 22:35:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554701754; cv=none;
        d=google.com; s=arc-20160816;
        b=lSfrt1masxzFYaXqNqq9ZFCAyDFknTZxroVKViZ7bG4JWdYK6ix1nr+aoOd8trXg6I
         bi/n5n8vpNACZz7uTAkZbZeAqPCdeaDefw69cDOFN2NOeQDB4WcSaNnGA0T1BrPxRzGU
         nwhydKwkzpkjrrYCyxc63h0E+xzb0P+BpzZe1Rh4jFclERlE/4+poKEotv6K7sJhTnb6
         6BfD2BWBTdhtl6YEpCyEw28ZCgsfKMeM0Vnsihl+eG/f5flk8OYe+AdWQeHEEKvRDcH+
         1Sp6jX//H1DJIKeQ2QbtEej6umD3u9SYeSMMr2FlXEe/cal3PgZFeAAW5XuHaiVaGNFw
         RjMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=f+SMtvytlSiOc/cu6kg/i2uCYQdbjbuO3DZI99pciYU=;
        b=kyAtCJNscAGdDYgfQE6EwwANbD20ICZSxm+CaLWQqpSR4AUyAxRWwKamYnGQns1WWU
         pHNqVYknOcXl4g3uAGDLgj75z12CMHwlsJDySLCSfy9Mabe3J4SW5Xt+PQoGbqgwmbOs
         ItoV+gGrrr7REOiIKIYf59NjOp//3Q3ni43I1IUObym7vF8I+7p5RhlPQwRYrY8yOd1V
         ofjFwRN1y2NEiY4Hhryy9oOJc/l3PjpbaQVQGB8JxNZyG7Mdqky/VdSTwGY1e+Jvpm8J
         31iDYXEL1BUODa9vOhGhB6k5YGr2uKARCeBAcyr0P7VhbV0eQMvoffMq997wXQ9OIdDw
         vrgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=UM8jkNe3;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t9sor1715087lfl.23.2019.04.07.22.35.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Apr 2019 22:35:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=UM8jkNe3;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=f+SMtvytlSiOc/cu6kg/i2uCYQdbjbuO3DZI99pciYU=;
        b=UM8jkNe3FivfjyjKQt0KIK00yEWIPKwCaxAzwPUf0x8n60fbSIe7PJodQN4uaQVDns
         2bDMJFFS6cD4Izl7uwOyaFlSvkFQ/2MiQxr23R+3qgHyeiIoZWHrQlBibOhl6rOOls/+
         FbEE0DkGCt2IM9u0wMFd7IOX0s6PcR3lvtyWQ=
X-Google-Smtp-Source: APXvYqxGn+omGlJMckrBiqlq37GsWCKM1WN4cNLOBum3UAzJXcbM35zhlO6O53bVBAVi7UYMJG5CTg==
X-Received: by 2002:a19:ed03:: with SMTP id y3mr13917795lfy.30.1554701753580;
        Sun, 07 Apr 2019 22:35:53 -0700 (PDT)
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com. [209.85.167.44])
        by smtp.gmail.com with ESMTPSA id q5sm5833786lfm.16.2019.04.07.22.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 22:35:52 -0700 (PDT)
Received: by mail-lf1-f44.google.com with SMTP id g7so8444621lfh.10
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 22:35:51 -0700 (PDT)
X-Received: by 2002:a19:f512:: with SMTP id j18mr9036020lfb.48.1554701750359;
 Sun, 07 Apr 2019 22:35:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190406225901.35465-1-cai@lca.pw>
In-Reply-To: <20190406225901.35465-1-cai@lca.pw>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 7 Apr 2019 19:35:34 -1000
X-Gmail-Original-Message-ID: <CAHk-=wgr5ZYM3b4Sn9AwnJkiDNeHcW6qLY1Aha3VGT3pPih+WQ@mail.gmail.com>
Message-ID: <CAHk-=wgr5ZYM3b4Sn9AwnJkiDNeHcW6qLY1Aha3VGT3pPih+WQ@mail.gmail.com>
Subject: Re: [PATCH] slab: fix a crash by reading /proc/slab_allocators
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, penberg@kernel.org, 
	David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, Tejun Heo <tj@kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 6, 2019 at 12:59 PM Qian Cai <cai@lca.pw> wrote:
>
> The commit 510ded33e075 ("slab: implement slab_root_caches list")
> changes the name of the list node within "struct kmem_cache" from
> "list" to "root_caches_node", but leaks_show() still use the "list"
> which causes a crash when reading /proc/slab_allocators.

The patch does seem to be correct, and I have applied it.

However, it does strike me that apparently this wasn't caught for two
years. Which makes me wonder whether we should (once again) discuss
just removing SLAB entirely, or at least removing the
/proc/slab_allocators file. Apparently it has never been used in the
last two years. At some point a "this can't have worked if  anybody
ever tried to use it" situation means that the code should likely be
excised.

Qian, how did you end up noticing and debugging this?

                 Linus

