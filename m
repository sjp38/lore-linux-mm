Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B81E0C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:54:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 674BE2183E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:54:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="h+CutXz8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 674BE2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B45A6B0003; Tue, 19 Mar 2019 21:54:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 161EF6B0006; Tue, 19 Mar 2019 21:54:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02A326B0007; Tue, 19 Mar 2019 21:54:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3E2E6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:54:10 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id 186so626893iox.15
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:54:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hdt+D6p9E7l7lnV6StTuQf0AYgJKugS80mLd0f4DexY=;
        b=dPe6nIC4OeS/7r1yjtcbaAyTfAUTHqd7d5TmRr5oegs8JLDw6ukpU+D/ktZkUhJcJv
         MvuxoDcZFCdPXx4sgyxx/i7AhaVr5hhXd6TZwweu5aq2f4fgM6HpgtDg1nAK7+B8zcJw
         FdBUNlh9Rdi2ZdKdYn/2zorApKFXIQfqYw4rfcRNoC5WYiPlJjNx+UAv4OfOeWI/Q1JE
         xh80R/gY8dACXAebZUOBgNRnTXBUnFhlcmWpEupW9Th+hhMklma14VKxn11G18d704xe
         Ht9KTTyHYTQVzqhXIUuqfqQr/LdYIhKTHHCKB382JG/9evL3436iNJEB4TtOVjwrcgPG
         f4Pg==
X-Gm-Message-State: APjAAAXq0/uQ+PsMYnw4rMaigzTA4W9m5mCOx3aqwZm//lDGfzVQd0YB
	/gkKWZgvhs9KgIVB+XtK7ecY4zFhrPFm/0ttVIHwFjSrHFKuQlE1mxH7hIWdduzztDCYeW/x5N8
	NAYNEILexxleG5DcUk2dyXU7nAg4VM2V5CPYmuqlp50ddeJl6aKNz+tqYZFlhh4hMuw==
X-Received: by 2002:a24:4692:: with SMTP id j140mr3487492itb.170.1553046850205;
        Tue, 19 Mar 2019 18:54:10 -0700 (PDT)
X-Received: by 2002:a24:4692:: with SMTP id j140mr3487476itb.170.1553046849577;
        Tue, 19 Mar 2019 18:54:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553046849; cv=none;
        d=google.com; s=arc-20160816;
        b=OzZGogpJEnwh9evzqrsIXeZGBzVQjoP6JUGYYkw+4Bjg11X7Y1YsK9irF2NMYkTuP2
         EEVd5VYqlrorF8vNgH6qIg3A3O1sPks6hCAmdfA4vu7K3VPnTkPE6bY0f0yTSeo1QxgU
         CmwTvCv94x9BpOoc7AphzAbs+e8QZQLy9jwDCewrozHWymS3ReelVx2OCRL7Z+JQqBiZ
         xNY7ny+eElacaXkl6cffaSaV8wT87GTus2+zU5pUbBfyDrpZvmyjTqbK8rkR8fOpuxZw
         BL0ggic90ljX9CTGM7V+0MddLcG0ucTCxhwsKJhrslShEHYEbOyZb6jVL315QXmXsp/h
         XEvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hdt+D6p9E7l7lnV6StTuQf0AYgJKugS80mLd0f4DexY=;
        b=byy2Gi+xnWFpK+rd0wpEpfL/kuv4qaFtOBElL9bIAVCEiLzP8FU31PtPW9mW5Wrbbn
         aQ8jbPhaU1SU7kUCUMQTHevweb0bfG8weI3/TmcURUdeJnDLzUZV2jjcjxGW7W5HyBI9
         vrLVi/WGrwo/LV2P6D3hg8E8VREP9VRyoyvP0WjoOwMXE3X73423zHdZc/fZ11dwPJSh
         Ffc1S4zKC0lFWxzrohHtQSTCEZLCIU6QHTe0oCP0K9nH9Fa0HnMsMGEO5jo+FgPBxwP/
         r79Ea31V0IY+4GCsn/htJg4G2NapkjNRMDgjDjDVIM/e/R+xMQytvIQBAWHi+3Xr0cAj
         t8dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h+CutXz8;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14sor371051iol.105.2019.03.19.18.54.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 18:54:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h+CutXz8;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hdt+D6p9E7l7lnV6StTuQf0AYgJKugS80mLd0f4DexY=;
        b=h+CutXz8gO4OJgPl4VPG+zVIErRIvBJ8IxVKR32U5P2BVfmfeiaWXN7ZnnV1dGf6fb
         Tk47u6O1mN4D5oYTSKa5XtllNaJr2T7aO4WIG9hhBUaxObEn7tCGDa6n4Hm27rE/gEFj
         d8B6FAW+YaLKbyQsPUaqaZR3n+2QTxBLkja8nEru3FSUt/wECjlLIYZqlA/Yw7VGSJJh
         3hnP5mpWolKnbsea1EaCRevc9gqsr2lSEAfK7tmp2V0kE5D+N4awLn2afGVYdLAWYoky
         s0OH+E3KsStUuymTAzcYImjUKzgt0oQZodQB4Hww8g+JYnFSxi27ETyPUOlkgoioW5eJ
         077w==
X-Google-Smtp-Source: APXvYqy58uB1G39PjKRQnEJaHqQLPKQNA3wtlDLGu6OkofTWBgV1yxorPTL6P/pMBq03FauOHAuxprk+ELik8kGEH/U=
X-Received: by 2002:a6b:720c:: with SMTP id n12mr3719620ioc.110.1553046849245;
 Tue, 19 Mar 2019 18:54:09 -0700 (PDT)
MIME-Version: 1.0
References: <20190319235619.260832-1-surenb@google.com> <20190319235619.260832-2-surenb@google.com>
 <20190320110249.652ec153@canb.auug.org.au> <CAJuCfpFEqv+x2GnSeU_JLQ3ahvfgNVPYyoRAxkDHcvVw-4r=jg@mail.gmail.com>
 <20190320111516.6e151efe@canb.auug.org.au>
In-Reply-To: <20190320111516.6e151efe@canb.auug.org.au>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 19 Mar 2019 18:53:58 -0700
Message-ID: <CAJuCfpHyGmhkF+LThARQTrcpAYf2ASMxLokE56dZcOEOHb7QtQ@mail.gmail.com>
Subject: Re: [PATCH v6 1/7] psi: introduce state_mask to represent stalled psi states
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, 
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, 
	Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, 
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 5:15 PM Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Hi Suren,
>
> On Tue, 19 Mar 2019 17:06:50 -0700 Suren Baghdasaryan <surenb@google.com> wrote:
> >
> > Sorry about that. This particular patch has not changed since then,
> > that's why I kept all the lines there. Please let me know if I should
> > remove it and re-post the patchset.
>
> As long as anyone who is going to apply this patch is aware, there is
> no need to repost just for that.  In the future, if you are modifying a
> patch that you are resubmitting, you should start from the original
> patch (not the version that someone else has applied to their git tree
> or quilt series).

Got it. Thanks!

> --
> Cheers,
> Stephen Rothwell

