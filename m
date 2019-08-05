Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 432E8C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 01:03:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBF5220880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 01:03:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iWafSLJa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBF5220880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D0046B0007; Sun,  4 Aug 2019 21:03:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4802C6B0008; Sun,  4 Aug 2019 21:03:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 397546B000A; Sun,  4 Aug 2019 21:03:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA2A76B0007
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 21:03:48 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id e16so17120170lja.23
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 18:03:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WmrFAHC07DlrBROd7WWwjkRjuc3qzI6oUcV/GoHKzYk=;
        b=ZWlfNrNneAs5upq7ronCzt8XBfBom5/82JX07bPodLb6zmMPRST7CzQFQv1NjWVCuq
         UOYo9+c+l6iwX02TirB2j9V/hezxz90oakeQgoUyzy+6Mx+VNoC89pUEsgyQGpji6Uz0
         zG1CZTiIhHYuWivK4mS9wiUJbm0AzV19zLpz+psWtzNP2NVklPD8D/mLGmuCYHESDUUh
         UxA9NCZ+UDfPYTpIdr6nJFujlBD7MmUuCwAIACLGb0K+2/J1Fm2ncz7ZcvlthMG7rzRk
         O1W15nbnLNBVi0hPbuQBDuHyP2aFwtsfUW26LFWxSwTgYGpXG0Na0k+rRZODWQ3uA1N8
         dZbA==
X-Gm-Message-State: APjAAAVeTrRtjEhQpf0xF6gkfsyoVhmxY67sei8fRuxtfWF06uCz2LA7
	3I2FspgQGUoL7NmbvS76E+zWPCgzVy5OEAWizPodRFd27bZGJ0xDJC7D1omJYtP6szW98OaCxG6
	ioGceuBYO1/sF4ggCIRU2d/V1aW+M9bGthb9RjuMBWwURbrzf2Pl8WvLPd9jY7p5/vw==
X-Received: by 2002:a19:c711:: with SMTP id x17mr69843270lff.147.1564967027932;
        Sun, 04 Aug 2019 18:03:47 -0700 (PDT)
X-Received: by 2002:a19:c711:: with SMTP id x17mr69843255lff.147.1564967027147;
        Sun, 04 Aug 2019 18:03:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564967027; cv=none;
        d=google.com; s=arc-20160816;
        b=yMb0OSIYKyw1NvSmWdUXlUs4kFd1JLxUtu/NDKHUt9AqOqq+cYvPJNMbByinnqVzgL
         4tB4wuNMgthC4MttQ2yUBSbchXHIwEelx1Q0b2lhrB+q4EvxBELkZtbaEpGy7w/yhb67
         302xkvoqwPD2mhag7D+joBofuNfs+lTGJG47ds89nrH6F2D6ebu9uz/3TtJc5v64Rir5
         FXolsj1nwVddFBS+As+NB4msumKq0BY7tEjypTZRFcD/nuMLQsFTrNV8FLtDdbV/XNPQ
         +0NEeRsYNC07nuq0Rb6iD5yhM0jZVEHC4TsoNazFOMzW5ws+rePD915BWwvemVf9Kx7b
         RNeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WmrFAHC07DlrBROd7WWwjkRjuc3qzI6oUcV/GoHKzYk=;
        b=VBsNcLICmsP2qxDWWvICaPLkJktA7ynJu95T/jCkMCFFlUSqBV6XIKXZdwEdc6XDXM
         tM5DoSKiqTK1plH1mvwOWbeVV/pKVaAlBYK7cr+COvJgURR8GvoN/bP+Hc4NzG02eh3X
         T3jICg56tWruKXq4X+r7Vk88Gqasm4EXbZH6Gqj4gqMBTf9nTy82p47Ne0Df4NVmqsFq
         fWNsjuOPe+h3+eu6uBGkIQUyNP4xGTdERpigFHk4HN29D4kpIpwMA31lcVU2KEjw49xf
         RNqv35EENfy0tfxgdRr5WQA1bM0qUL2mRDbhwWMV6iJAj+6PxZvrwV3CFBuQM1Wl7WRN
         bl3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iWafSLJa;
       spf=pass (google.com: domain of airlied@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=airlied@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v7sor20797321lfd.58.2019.08.04.18.03.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 18:03:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of airlied@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iWafSLJa;
       spf=pass (google.com: domain of airlied@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=airlied@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WmrFAHC07DlrBROd7WWwjkRjuc3qzI6oUcV/GoHKzYk=;
        b=iWafSLJaEp0VfnD00FV8DkZCUUcui7hR/eLGX47Wh4alduSlUkHdl2PLoX4j7wOFa7
         6ioeaUayLRoYahIpLPfCvenkZhbZa2hGi8TR1xpLJB0APzD8KaDBmk19+sSntPXAP6Jm
         apFDkyNwhJuMQbTmX+wVAmuSpgEOMg1RZ3QZo0pNu46Au5ZsIY6O4fyEMXd7Qjytukj1
         gCY1722Mgxhy25un956dYmMT9K5cmutcjHyf3K0uuoTb7d0oSE1caneCpy2NY5EnQj7w
         0cwKdkXDQEX7VhwGKXsDqWdsgURGy7ulZu+0cfXEdfOOc1Ggr7LB4JYDU/WTWcFVDkrI
         D0gw==
X-Google-Smtp-Source: APXvYqySxgn/5teLdmDwFi+c6xRp59f1ywZmW6wEWVf6qrCjqr3LJLIRyhDIvjAYIsznufd8BX4pO11hDUMPPEIQZIw=
X-Received: by 2002:a05:6512:4c8:: with SMTP id w8mr4546391lfq.98.1564967026478;
 Sun, 04 Aug 2019 18:03:46 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsNDYzcpDCM5P0fVWF30N+TMD62CXjv902z39mrCWULsjA@mail.gmail.com>
In-Reply-To: <CABXGCsNDYzcpDCM5P0fVWF30N+TMD62CXjv902z39mrCWULsjA@mail.gmail.com>
From: Dave Airlie <airlied@gmail.com>
Date: Mon, 5 Aug 2019 11:03:34 +1000
Message-ID: <CAPM=9tw5By7txR8UVriLxyveX0kff3aNNiMWCTjbVyk33wp5XQ@mail.gmail.com>
Subject: Re: The issue with page allocation 5.3 rc1-rc2 (seems drm culprit here)
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, 
	Harry Wentland <harry.wentland@amd.com>
Cc: amd-gfx list <amd-gfx@lists.freedesktop.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Aug 2019 at 08:23, Mikhail Gavrilov
<mikhail.v.gavrilov@gmail.com> wrote:
>
> Hi folks,
> Two weeks ago when commit 22051d9c4a57 coming to my system.
> Started happen randomly errors:
> "gnome-shell: page allocation failure: order:4,
> mode:0x40cc0(GFP_KERNEL|__GFP_COMP),
> nodemask=(null),cpuset=/,mems_allowed=0"
> Symptoms:
> The screen goes out as in energy saving.
> And it is impossible to wake the computer in a few minutes.
>
> I am making bisect and looks like the first bad commit is 476e955dd679.
> Here full bisect logs: https://mega.nz/#F!kgYFxAIb!v1tcHANPy2ns1lh4LQLeIg
>
> I wrote about my find to the amd-gfx mailing list, but no one answer me.
> Until yesterday, I thought it was a bug in the amdgpu driver.
> But yesterday, after the next occurrence of an error, the system hangs
> completely already with another error.

Does it happen if you disable CONFIG_DRM_AMD_DC_DCN2_0, I'm assuming
you don't have a navi gpu.

I think some struct grew too large in the navi merge, hopefully amd
care, else we have to disable navi before release.

I've directed this at the main AMD devs who might be helpful.

Dave.

