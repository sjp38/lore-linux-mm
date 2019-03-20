Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38FA4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:07:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF6A92085A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:07:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Bur//thX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF6A92085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90CE96B0003; Tue, 19 Mar 2019 20:07:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BBF06B0006; Tue, 19 Mar 2019 20:07:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 783E16B0007; Tue, 19 Mar 2019 20:07:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 488CE6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:07:03 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id j127so601755itj.7
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:07:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eXp5qzoLPE5k4y/K+1OpvTbOH6oNQxSHAXnNXH0YvjQ=;
        b=bmSRobGrC1r+bhDP87m5dxwEQ+fjAKhAAG4DVfGfcgO8w9UiehTf5zlRdhjPs0q84d
         U9evA3XFkSi9vMdDEUxp2+phXvMoO2ElIbzXCrg8zQxBHdQXzrM6NqvpK2ykaOdTP9uP
         Rb9KzzD7nB8VixjVCQ+bsdWHLswifwhd9f1T5BtrPBDs88hedBpm/DPQLk41uqlzD9H+
         tS1np/obPARAdCMRJPvJzmRHeIaG0ioYzeYFVFlL2FT3zQkVribQUcYbNzviVq01cNOK
         w+QL7WvcvBMx+rdx5az8POr75c/smgICFVkaR3WSbprg3FkcDk5gHRjwYzoLdfN55Mu4
         UqJg==
X-Gm-Message-State: APjAAAVFi6Z4JJo/0MlSnpY39vbyfiLAlqIOUlPZ0GFEmVBIkL8OW1G6
	UENLfvJL8ZFWWh1fGrUJQjYxe4BNuDc0lM/Ki5sQr7pwgqeQ3Klcy2zzk0TZ5TddN8QeijLz35A
	BXspu5rm/WUthm46xpEJMSCO7MJ398NUIpG7F13LMs6wchYgcEyPqB34j1k01/Lhx3w==
X-Received: by 2002:a02:5541:: with SMTP id e62mr3210157jab.88.1553040423044;
        Tue, 19 Mar 2019 17:07:03 -0700 (PDT)
X-Received: by 2002:a02:5541:: with SMTP id e62mr3210122jab.88.1553040422336;
        Tue, 19 Mar 2019 17:07:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553040422; cv=none;
        d=google.com; s=arc-20160816;
        b=VuVLFiRVKAoq/QaV3/1+VFkqNj6ecx6UjORElAyzIliKuHfZnLVH7KF6XFKpQWNt/9
         SF2O0+fQxvEON5GQGxppMBpmey0jxGKf+myAYzjk/i20REjbIGstXv+gQAG0IFdLZMPi
         fhtMzNtb/YtBLEWGoaC+isb7vtG5fbvBcTBd5JuDW77xhko+cYeifE+Gtu+3Cihzl4vP
         MzR82BdunUMkgJSi//RohYZKk1WteONS8/5PE9R7g9N+9KzXOMf0I/VCYssuMAJXEbeg
         uRg6ZfImT4+tKbejmv+esDOxFzJgTdIuvqUD6L0fYW0rdIy1vn4dH0KU5LaicnMViDB/
         ys+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eXp5qzoLPE5k4y/K+1OpvTbOH6oNQxSHAXnNXH0YvjQ=;
        b=b8sSy53uURg/0hzqRSw46Q3IRNIrhTHExwDBleEcXN0Zym4E9FRo3mH1iOMs0Fh8J5
         o1d5jng5FJZ2C3tHl4Mq9UDTUpe8ZAiN2EfULGkAXF3wzMkPlP9zN+t/DpZtKrSDHP8w
         xZOhP1oRT2xqy8XtXM+h1MLCungtnYmdYZMaENbfHGkl0QmF1ddYlJ2A8U/WMV9sL+Xz
         TyUl46nQ5NNIj8pePHGIR+nH5kQCu4F9VuiFdoaGgkuPQbUzJEAsEoZak07ovL39boel
         /hF6H10li0x+w+0RQ7jZkoI02M9z8Zp5UEdKDSpRySpnjSzW0/JUlUVqQnOx2uE7DK5a
         nqJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Bur//thX";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i71sor567070iti.25.2019.03.19.17.07.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 17:07:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Bur//thX";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eXp5qzoLPE5k4y/K+1OpvTbOH6oNQxSHAXnNXH0YvjQ=;
        b=Bur//thXopzVgwZJB7yIAIDhmYXnRCW6LthfE+610t5jV9d54r7SkeAhSSh8y7m5Zi
         /VYoJUghb4zWk2ojIaQffbFmDWXT5+bSZxdnlF7xlaiuqSmcuXM7hfN8cGLJdRvmIci9
         9clf/LGQ2TUf6AkWFIeRNei5APFL9r/bwC/QYUd3l50LdBZS9ZToLA6jD3+rtGvnqm4t
         Hvbd1dGMzUi904201WtqeTnm2oO2HTyGosAFtQKafrUe5JlbyCWgfcLxhCjEOItETDoJ
         fLwgwJu4UfNt1ZvkV5b94Nt2z/ESi1u4CI5ogvLA6g7WQlp0a6cLY4DS2b4oiX68xyV5
         nG+w==
X-Google-Smtp-Source: APXvYqxACcBTRJSVb4DHcEzY2QbcyAKr+kyAJ4K2La3j+RkpHtiIIgkTpuc49OGxv/1+jAeKgj6GGDSbgMHi8Zacago=
X-Received: by 2002:a24:3c53:: with SMTP id m80mr3376403ita.102.1553040421935;
 Tue, 19 Mar 2019 17:07:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190319235619.260832-1-surenb@google.com> <20190319235619.260832-2-surenb@google.com>
 <20190320110249.652ec153@canb.auug.org.au>
In-Reply-To: <20190320110249.652ec153@canb.auug.org.au>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 19 Mar 2019 17:06:50 -0700
Message-ID: <CAJuCfpFEqv+x2GnSeU_JLQ3ahvfgNVPYyoRAxkDHcvVw-4r=jg@mail.gmail.com>
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

On Tue, Mar 19, 2019 at 5:02 PM Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Hi Suren,

Hi Stephen,

> On Tue, 19 Mar 2019 16:56:13 -0700 Suren Baghdasaryan <surenb@google.com> wrote:
> >
> > The psi monitoring patches will need to determine the same states as
> > record_times().  To avoid calculating them twice, maintain a state mask
> > that can be consulted cheaply.  Do this in a separate patch to keep the
> > churn in the main feature patch at a minimum.
> >
> > This adds 4-byte state_mask member into psi_group_cpu struct which results
> > in its first cacheline-aligned part becoming 52 bytes long.  Add explicit
> > values to enumeration element counters that affect psi_group_cpu struct
> > size.
> >
> > Link: http://lkml.kernel.org/r/20190124211518.244221-4-surenb@google.com
> > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Dennis Zhou <dennis@kernel.org>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Jens Axboe <axboe@kernel.dk>
> > Cc: Li Zefan <lizefan@huawei.com>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Tejun Heo <tj@kernel.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>
> This last SOB line should not be here ... it is only there on the
> original patch because I import Andrew's quilt series into linux-next.

Sorry about that. This particular patch has not changed since then,
that's why I kept all the lines there. Please let me know if I should
remove it and re-post the patchset.
Thanks,
Suren.

> --
> Cheers,
> Stephen Rothwell
>
> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.

