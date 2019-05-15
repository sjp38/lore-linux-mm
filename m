Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E2D1C46470
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:47:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D2172084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:47:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BB0dY/8F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D2172084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1D8A6B0005; Wed, 15 May 2019 14:47:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F4F86B0006; Wed, 15 May 2019 14:47:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E3416B0007; Wed, 15 May 2019 14:47:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6317F6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 14:47:03 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id x23so458884otp.5
        for <linux-mm@kvack.org>; Wed, 15 May 2019 11:47:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eOydKc/WsPS/4UYaw0lrBxS07NNolXo/TbnO9qPBOqA=;
        b=qkkdciwrlbQSZl0pHZnmzogpAbwA/8+sLePtcAhpRkDwUSuXJ58fnssfYZOrxpmTkE
         3xxNTkH+Bne6mnZp0IPUlo2A6h+cFjWE/m+8ALb5HGIdnzIEW0XGt97TfrduXJZrn7GB
         FR1Cdu0a6d8706OBd3IKtdI3v48yV/s7XgAUr1PLVF/XuwQC7EF+xvrCkHr32zxsERhn
         w3YMnP8hplSwxDl8WlsVW4DiCrELi9dKECmUQBzojnAN2JQO7C4iIlsx1O6qp8+273Qy
         yNS0Wavk+Jhi1ghiRBjqiDRzBpLpCySsQmHF7QjY6phQkG1+EOpKjVniNZ8ZegJ207w0
         giXQ==
X-Gm-Message-State: APjAAAUwtedTp8ZTTuAMr0LpyAEYvAoqWAsIzbc7vaJTAbh5cp63V2vL
	uCbeW9g4EyQWqBV/K/Q1N8qyGchiTgVo8Ox9JKEi/dfMKpOoW7dC1u7IPzx5V4oufu/vqF9mctI
	SBFIPsi8PQXIbSNYlu5iJvadgehFiA1+8uH1AsMJgrLWC4hPF6l4lFgKstx2asnH71w==
X-Received: by 2002:aca:fc95:: with SMTP id a143mr7979630oii.128.1557946022929;
        Wed, 15 May 2019 11:47:02 -0700 (PDT)
X-Received: by 2002:aca:fc95:: with SMTP id a143mr7979577oii.128.1557946022213;
        Wed, 15 May 2019 11:47:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557946022; cv=none;
        d=google.com; s=arc-20160816;
        b=cHLzuWY5NF772dxLthFE1okV5I7CEEJcPq3FtJefVvQ/EZ9m5eKVT5Z9DjsoeK/sAv
         U8zFWgP7joahe5WkeJ/3IRgwIgMG+XN4d8WHLoAm1x2JQ18n3Jy8rkNI/vlDU9uXq5Q3
         3aWQyKaZJbstcsoR39KP2s8/xezf0Fui4VvkBlcbt8KJfD69UczdoICkX7d1PQt6pe/K
         98nS0Jai+HzEjnzETbtnyxCsztzPuG/b+RgHj1IsuLxh8zGw99ayU8TIXkn8iSXv2VEV
         LnJo95C1Dhinn3zQ0IHh2C0ateAKP6I0duz5mRlLM/gvSa8m5jL7j1jbcKQEq74YCPD/
         ABIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eOydKc/WsPS/4UYaw0lrBxS07NNolXo/TbnO9qPBOqA=;
        b=IVwR61D+JGK8vWSQvc3AxTrA8KBaedEA95EVHPD5S2OW1ozGLwnlWij8yyFqo3TEFg
         Bc3vwXWeMr7Sm2v2dUBcbgBYOMWLlVGh3MwjtNVCymbUAgGtr5l5zOFcrzmA212UNsmm
         P0nuEDnpsYI8MhEk7AKKcxJPRcrbx2JqpAGpO6LnTIjRpj2hC1qacG9m9QPBuhVP32Rx
         uYb0uRRIEWVZOX0mkt8riW3b/5I3lECIeIeCJ56mqRJNajI+p+3ag0PXW3rlij0cLnP9
         a6wwjqCWbT7Lok6hYXt9gzNaBOvtcYHMw7CvFBhriesN8b6Inp9EL52m/5aK5ErUlQp+
         Bt8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="BB0dY/8F";
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor1468876otj.104.2019.05.15.11.47.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 11:47:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="BB0dY/8F";
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eOydKc/WsPS/4UYaw0lrBxS07NNolXo/TbnO9qPBOqA=;
        b=BB0dY/8FNByRR2LvoUO/dEX3U9iTwiAuD6aHdfRN6ftwVYsE1IArfACRpd3ZCZsY6K
         iY3gRSmuhRSwx1CCfGKDmeD+9JrqnQ2zFP92vPEOcQ5dHRWplBxKaMngMkcjtvxNhwfT
         wL6ijfW2WUojZfxbnR6DoqNlpDaHF5luAmcZLddGp/55FRptVwDp2UodImztRLRvOzPs
         e5IB+BeCcv9nlxmyfXT8di+B21J2cX9v6Gd5YYKTdpx0iAi8XF81A8RwPD7taUw9keMH
         LkGSy82DcXdG4vNpjS9JmmDLH853rSylPUd3weZDpNk+E1kXpdMxe0+rTLTqf9jCo9H0
         cZ1A==
X-Google-Smtp-Source: APXvYqyal1aN8n2OsssxIrvSlvaLMFF5ulsVEFJWHTDanNfWzlN/kwAPewVzo8zGug4MCn40y4+zwPV0F7AvsRqjAxs=
X-Received: by 2002:a9d:5f06:: with SMTP id f6mr26196019oti.18.1557946021528;
 Wed, 15 May 2019 11:47:01 -0700 (PDT)
MIME-Version: 1.0
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
In-Reply-To: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
From: Jann Horn <jannh@google.com>
Date: Wed, 15 May 2019 20:46:35 +0200
Message-ID: <CAG48ez20Nu76Q8Tye9Hd3HGCmvfUYH+Ubp2EWbnhLp+J6wqRvw@mail.gmail.com>
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, 
	Michal Hocko <mhocko@suse.com>, keith.busch@intel.com, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, pasha.tatashin@oracle.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, ira.weiny@intel.com, 
	Andrey Konovalov <andreyknvl@google.com>, arunks@codeaurora.org, 
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@surriel.com>, 
	Kees Cook <keescook@chromium.org>, hannes@cmpxchg.org, npiggin@gmail.com, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, shakeelb@google.com, 
	Roman Gushchin <guro@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, 
	Jerome Glisse <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, 
	daniel.m.jordan@oracle.com, kernel list <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 5:11 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> This patchset adds a new syscall, which makes possible
> to clone a mapping from a process to another process.
> The syscall supplements the functionality provided
> by process_vm_writev() and process_vm_readv() syscalls,
> and it may be useful in many situation.
>
> For example, it allows to make a zero copy of data,
> when process_vm_writev() was previously used:
[...]
> This syscall may be used for page servers like in example
> above, for migration (I assume, even virtual machines may
> want something like this), for zero-copy desiring users
> of process_vm_writev() and process_vm_readv(), for debug
> purposes, etc. It requires the same permittions like
> existing proc_vm_xxx() syscalls have.

Have you considered using userfaultfd instead? userfaultfd has
interfaces (UFFDIO_COPY and UFFDIO_ZERO) for directly shoving pages
into the VMAs of other processes. This works without the churn of
creating and merging VMAs all the time. userfaultfd is the interface
that was written to support virtual machine migration (and it supports
live migration, too).

