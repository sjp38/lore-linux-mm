Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 461FFC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:29:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28E83206A3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:29:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lO6qF6x/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28E83206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C3526B0006; Thu, 25 Apr 2019 16:29:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64B5F6B0008; Thu, 25 Apr 2019 16:29:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53A916B000A; Thu, 25 Apr 2019 16:29:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 370F96B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:29:47 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s23so921586iol.20
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:29:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OeRjZGIi29J9UcGvV4ntvpRnkfTKsCp6AYnhMmfL4PQ=;
        b=IINXqsCFbaQxWUdlgDPvxX2SiTjgwW0QjDH74Lall3bFAls3izmpjsPU7NqykKVQW1
         /oNgvNZiJyDG5oxmC9brmuCqeGGG73c0FOvf30+Bmcrl+dEarBQpH2+P/8w/HluIiJDZ
         DHXwj/vlW8qOfx4qZEkJkQ8PnkoYjZ9w1YS/xcb7FdnEiozrMke9WhEroktQoVA033he
         yS0zSWtHSFlu0Nr+mPnGC6IcSHMPIh8Y803nn9xvTj9U/YKTJ4xokZbiCHwbrU+AvmLg
         hMkBZ4qmp2j5z4Z1zyBciag/QXn52DZy3QCqlSpZRHzh0PjkRCOyb+EXKgB904Z0BF1M
         OaWw==
X-Gm-Message-State: APjAAAXsPmieB6NyNIs5voYFyPTnW16fKbvEBSBZkdXfUmUS7YnDM5Ak
	yVx5AsC0JBYBtk3Z5go+KBPVyij4TqIYQBsXY85U9qXC2hMr+JxWYMtfsR/GzFEcICeSbIQGokR
	uiTQS8onhEMhSFxq6eIvlFlHNWNNtZIkRU6nYoOQuX7rjsigaegLqyoWBgznjvFliAA==
X-Received: by 2002:a02:ba13:: with SMTP id z19mr29220833jan.136.1556224186932;
        Thu, 25 Apr 2019 13:29:46 -0700 (PDT)
X-Received: by 2002:a02:ba13:: with SMTP id z19mr29220792jan.136.1556224186188;
        Thu, 25 Apr 2019 13:29:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556224186; cv=none;
        d=google.com; s=arc-20160816;
        b=oVucQtgPFNyVeE8sa2FadFHizMZhtrhwVHenorWrkU4AYaObBONL0mXn6l7pjrXrTK
         Dw37CwQUUl1/h+kD0/IKzFUzGGK9UsMKHjUzw2NaKOA0hAuntc2frVE85odY0XrJhU6p
         irUmnX44QMgCn2ZcYJwRcrqFKltg+4WsKFnHpH8JLvsVgE0Pde6zjhWIIKMSKUISnWjk
         cBRZJQFIkVc+J90I44i7jwQAGt+FRoQ8JsRtNHgi5TJNQqs4q+DexORBpomfZORQL+qa
         3YihUuvJeynL6NN9S22uiu3G8ZUaWVI9EVb7rdjzjD1Mpv72oTv4SKPCX19AGAr1+H1o
         iypA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OeRjZGIi29J9UcGvV4ntvpRnkfTKsCp6AYnhMmfL4PQ=;
        b=VthUd2MzD8alKuHoOl7LSgdzHzmqK0B2IQUP69NTTuAW0Vuo5K4C6StA1IqvU37fqu
         /t64B+6ziwJHOJGTYl6k5cot+em2DTC8m+UHRfOVu0G6hGZlFJUdxMEETXH4oOFwSd+C
         seW7r42PQcod7kbVYk5HA9MuO1X7+l8Bv7voWziXVfeJkCPFlYTchXKMV1hibtaLrZZh
         wstW8TzUY0LzATbWKL+pG+LCpEy5TKZHJytsBBOk3pwgcjJCSLy7M5u/GhgeFv9ZQpQY
         rfnRF8hlsjUWPu8/P0k2/Sxmi6M0gUQXXBtW9h/QIX6o/oHSMlMD1of8UPQXkZIbJDrR
         gYmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="lO6qF6x/";
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g75sor2896575itg.0.2019.04.25.13.29.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 13:29:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="lO6qF6x/";
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OeRjZGIi29J9UcGvV4ntvpRnkfTKsCp6AYnhMmfL4PQ=;
        b=lO6qF6x/lsmtbgZV7Bw2GdcM06jup7E4clccinkLC7oVx6jtRxGjeWolacT+lr/2f8
         oUEWqQrVXjfAqipfNz0HRbf108oLI5dZ03xBc8ZWzK2S6+hjw7ZYo3/zGCrFlhQDx/9E
         T+yHpyYho4gisZp2aEMZZtURuZC62A5hRh7ON5uOxwYCLxTAOiESvK/stRcCcmONoPjK
         nXBHASXzEntp/r4hNSR2RsB3e4SgCtVSN1/sTOrRtaGT8XpIIeAlqnTzqxKQveAWz4zB
         84vJH2Ab7t1rA96aTrVHCLO4zJrj2YR+r6jUKFnjnFdlhrUeg790QgMv79o8iy9wvQrV
         jg2w==
X-Google-Smtp-Source: APXvYqxCCyQ8DGk96WCnOlOChzZ2LUpTOEO0t7U28XHmQuV7D6Ak8m/yQN8PJ18mYwH7ldueo1fA0A+bC6+AwLEozUE=
X-Received: by 2002:a02:c955:: with SMTP id u21mr29477992jao.105.1556224185529;
 Thu, 25 Apr 2019 13:29:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190424191440.170422-1-matthewgarrett@google.com> <0100016a55209db0-efc46978-fa1e-48be-b17a-fcb6b58ae882-000000@email.amazonses.com>
In-Reply-To: <0100016a55209db0-efc46978-fa1e-48be-b17a-fcb6b58ae882-000000@email.amazonses.com>
From: Matthew Garrett <mjg59@google.com>
Date: Thu, 25 Apr 2019 13:29:32 -0700
Message-ID: <CACdnJuuZ37Bs7NtzdN-AiPhZy7B+EMphutDxxYFTu6k=j1ugqw@mail.gmail.com>
Subject: Re: [PATCH] mm: Allow userland to request that the kernel clear
 memory on release
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 8:32 AM Christopher Lameter <cl@linux.com> wrote:
>
> On Wed, 24 Apr 2019, Matthew Garrett wrote:
>
> > Applications that hold secrets and wish to avoid them leaking can use
> > mlock() to prevent the page from being pushed out to swap and
> > MADV_DONTDUMP to prevent it from being included in core dumps. Applications
> > can also use atexit() handlers to overwrite secrets on application exit.
> > However, if an attacker can reboot the system into another OS, they can
> > dump the contents of RAM and extract secrets. We can avoid this by setting
>
> Well nothing in this patchset deals with that issue.... That hole still
> exists afterwards. So is it worth to have this functionality?

On UEFI systems we can set the MOR bit and the firmware will overwrite
RAM on reboot. However, this can take a long time, which makes it
difficult to justify doing by default. We want userland to be able to
assert that secrets have been cleared from RAM and then clear the MOR
flag, but we can't do that if applications can terminate in a way that
prevents them from clearing their secrets.

> > Unfortunately, if an application exits uncleanly, its secrets may still be
> > present in RAM. This can't be easily fixed in userland (eg, if the OOM
> > killer decides to kill a process holding secrets, we're not going to be able
> > to avoid that), so this patch adds a new flag to madvise() to allow userland
> > to request that the kernel clear the covered pages whenever the page
> > reference count hits zero. Since vm_flags is already full on 32-bit, it
> > will only work on 64-bit systems.
>
> But then the pages are cleared anyways when reallocated to another
> process. This just clears it sooner before reuse. So it will reduce the
> time that a page contains the secret sauce in case the program is
> aborted and cannot run its exit handling.

On a mostly idle system there's a real chance that nothing will end up
re-using the page before a reboot happens.

> Is that realy worth extending system calls and adding kernel handling for
> this? Maybe the answer is yes given our current concern about anything
> related to "security".

If I didn't think it was worth it, I wouldn't be proposing it :)

