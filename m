Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67658C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:51:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CB9421473
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:51:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pT9gnBiI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CB9421473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B38A28E0002; Tue, 29 Jan 2019 16:51:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE8F48E0001; Tue, 29 Jan 2019 16:51:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FE7E8E0002; Tue, 29 Jan 2019 16:51:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 747638E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:51:51 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id j5so26100224qtk.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:51:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4J4EPFzhpTYgapq2/5ZPc5bcmOf41JDyTiTqV/mvITI=;
        b=jdJMhKadCMhCQBMA6WdFTcgbvNDfdhebCHiypZNPb7HeCgmEOH8khNJ93GsLwpfv45
         8mebMxSYFY61k4NQrf2tNrLa3xaYgCL3mbdRbkyexR7bTUVZF094adEJGIUuAloEy9a9
         MiNRLtw1cJE/hPdVrv/gZ07B+vXhZcQjAuXUu/sPJCS//4RXwo3c1U55R/457KYGqFFO
         8wxLI8TqbQsVUyHJ+aexeFCnaZOkQcieak1b+UPyF5+FGYmemPiyvJhD8W5qAyq0nCL2
         5MuxDeC+QyqfVh0V9QjBrg9/Td3WqLGWgh1E0yQestyMzSf/FYdyzAP2EiZ7RpUjlPa9
         zgZg==
X-Gm-Message-State: AJcUukfkcJcRwE6jXTk5GTlOoT5IW9+GnQOhXJ9xVvTakDYlCf/FcBTh
	MLiCcQRNcWEZeTIi/dUWSSWzOWaeHF8Y60l5NsqpYgSnMstmlvAlds1H1mdADQIo1DqKH18mssl
	9UNetCk/MJHFiKvAlJTFVdOTcpR8apAPHMUjmYeF8KyJ6XFArCdJE2An/3REt3hFXEGlpnqq8NK
	BpcsTZa3yKpHh20X1mb2tm0SprBHQ+gFNkavW+YaU7apf1+RgI/bLja+KG72sRoKAUwiTanGvqX
	IJQdVtncNT7Ec8gP73Wa81Oals+lhykLO7ZqSoPWVLtdfCyFqetb2Dw/0ag1WxnhDv1zFTwb7Qs
	XFaJ9C4teB+5xyxehcLq1Fj4AKhodZr5aSiGr+/GuZ9T5Uiru14ArWrxjm5R0Ap+DRq1/gouR/k
	t
X-Received: by 2002:ac8:7416:: with SMTP id p22mr27227994qtq.318.1548798711224;
        Tue, 29 Jan 2019 13:51:51 -0800 (PST)
X-Received: by 2002:ac8:7416:: with SMTP id p22mr27227972qtq.318.1548798710685;
        Tue, 29 Jan 2019 13:51:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548798710; cv=none;
        d=google.com; s=arc-20160816;
        b=HQh//WmH0DeMf8xkiTwqhNrKgieHV7CqixhQu2x5p4tb+pWiiaStrwOxOFRNfNL4o5
         /zpGQI0cixKVULf/IvcHBqIV/6qfFAq0I6hyqDAZHWihM8lSsEVkA6tg+QramQ06ViJo
         ykuSdiWhHGTuqoz+uwPKNq3V/UFChAXW96J4Uy/SsUoruXZlV2sxmaSOaOzeD87iRj6t
         +bRRcVOxqz4O5dRZ42qijVfXTX4lr9Q00LVMgeSgShIbZFhFPAbCOXwE1DHQK/rQA8SJ
         0UtNLv1EAZTmtc3gKba19AnT6rx1zeJEdvvzgJHKG7pcmmQ+uMPQByTJysY1b1IX3/+F
         92vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4J4EPFzhpTYgapq2/5ZPc5bcmOf41JDyTiTqV/mvITI=;
        b=pXU+EPHAjYuGtaXCOGIZxtBOyU/oqEJQFpi9l9LSS7EZAPUPDUMaHtxjM10FCmwfRt
         pyYRDmx8CKrNnG1qHFPK9uHs16dhdB4q/RxYwvtQzNqdg6LBMIZ8i3PTZMQzZ5L5zBpp
         fRRqKLbxe3JREjFQhaj+EoxuYVxMfGSHGGL/d9Um+5WBMMDAkBuZ4fbHyNpu/jMtVlkD
         3VBh4/pwtaBj4yV8Najd4PaNQPSXOIpTF14D3nq9JvPO8+YUaE8onPO8j+T3rMYiYUw8
         pLK/YEYMREMWAGG2nRZ4y+Jy73ktnHYGNBllYW6JWVsHX4GhhFbL3zNZgiaxay5+PLiD
         GB2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pT9gnBiI;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l6sor139555082qte.24.2019.01.29.13.51.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 13:51:50 -0800 (PST)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pT9gnBiI;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4J4EPFzhpTYgapq2/5ZPc5bcmOf41JDyTiTqV/mvITI=;
        b=pT9gnBiIBd0O86d4ycqIKi0ZWLvh01kY0idIR+6D66Lu9DVlsKDzERgXzEO4jJQwEy
         l4LBc7fyyS92qK5EHn65d4ZaCqwV9mr40TggNOLQJHTX6xfIQdoW/FmMQfF9SmZvDI7Q
         PMVcv4jn8scKPN/crLRe18REK2jmD79MJeQoQuERyJeCIyU0JqaOaapYpy8zcG2L5usl
         DO12fnXftoAG1rSHjZLxRyY7G/28yek/I6+X0sDNQwhNCJ2T7B8qUVk6LxIStNN/CWjs
         MQapcjd8hMCbTV5n3bllD0w6UktyZcUXQZwlRp60C0ZfSo9PCk29iHFq/Jdhm7yGDK1k
         T44w==
X-Google-Smtp-Source: ALg8bN4Qa+hXKEDkw0disn55wWlnq68aAtd6k5WOlHkMxsXDzCSVYjYciL+FcTqTG5tOtaF0wrXlm8hTNUbPb74uPIU=
X-Received: by 2002:ac8:74d7:: with SMTP id j23mr28251710qtr.369.1548798710510;
 Tue, 29 Jan 2019 13:51:50 -0800 (PST)
MIME-Version: 1.0
References: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
 <132b9310-2478-19e1-aed3-48a2b448ca50@I-love.SAKURA.ne.jp>
 <20190129111346.fbb11cc79c09b7809f447bef@linux-foundation.org> <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
In-Reply-To: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
From: Yang Shi <shy828301@gmail.com>
Date: Tue, 29 Jan 2019 13:51:39 -0800
Message-ID: <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiufei Xue <jiufei.xue@linux.alibaba.com>, 
	Linux MM <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com, 
	Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 1:12 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/30 4:13, Andrew Morton wrote:
> > On Tue, 29 Jan 2019 20:43:20 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> >
> >> On 2019/01/29 16:21, Jiufei Xue wrote:
> >>> Trinity reports BUG:
> >>>
> >>> sleeping function called from invalid context at mm/vmalloc.c:1477
> >>> in_atomic(): 1, irqs_disabled(): 0, pid: 12269, name: trinity-c1
> >>>
> >>> [ 2748.573460] Call Trace:
> >>> [ 2748.575935]  dump_stack+0x91/0xeb
> >>> [ 2748.578512]  ___might_sleep+0x21c/0x250
> >>> [ 2748.581090]  remove_vm_area+0x1d/0x90
> >>> [ 2748.583637]  __vunmap+0x76/0x100
> >>> [ 2748.586120]  __se_sys_swapon+0xb9a/0x1220
> >>> [ 2748.598973]  do_syscall_64+0x60/0x210
> >>> [ 2748.601439]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >>>
> >>> This is triggered by calling kvfree() inside spinlock() section in
> >>> function alloc_swap_info().
> >>> Fix this by moving the kvfree() after spin_unlock().
> >>>
> >>
> >> Excuse me? But isn't kvfree() safe to be called with spinlock held?
> >
> > Yes, I'm having trouble spotting where kvfree() can sleep.  Perhaps it
> > *used* to sleep on mutex_lock(vmap_purge_lock), but
> > try_purge_vmap_area_lazy() is using mutex_trylock().  Confused.
> >
> > kvfree() darn well *shouldn't* sleep!
> >
>
> If I recall correctly, there was an attempt to allow vfree() to sleep
> but that attempt failed, and the change to allow vfree() to sleep was
> reverted. Thus, vfree() had been "Context: Any context except NMI.".
>
> If we want to allow vfree() to sleep, at least we need to test with
> kvmalloc() == vmalloc() (i.e. force kvmalloc()/kvfree() users to use
> vmalloc()/vfree() path). For now, reverting the
> "Context: Either preemptible task context or not-NMI interrupt." change
> will be needed for stable kernels.

So, the comment for vfree "May sleep if called *not* from interrupt
context." is wrong?

Thanks,
Yang

>

