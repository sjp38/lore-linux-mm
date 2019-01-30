Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.2 required=3.0 tests=CHARSET_FARAWAY_HEADER,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09B94C169C4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 00:42:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DDBB21473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 00:42:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DDBB21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 081B68E0004; Tue, 29 Jan 2019 19:42:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 008538E0001; Tue, 29 Jan 2019 19:42:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEEB48E0004; Tue, 29 Jan 2019 19:42:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABC818E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 19:42:13 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id s204so11478146oib.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:42:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:mime-version:date:references:in-reply-to
         :content-transfer-encoding;
        bh=7xnPD9DL3i0s8BYCf2DaG9QAXv7qVlKoI7Tx04pb5xA=;
        b=s05dLOf1ugMsc+EB8sQvPzLTqeF9vNS/xOyTChmIQrKRATWEgzrXnk+pp89Xh2W8su
         Qlg6svhjt2ZnZwQnZAhxIcgMazqXdBd8Hw72tkNk45RoeEred5KyBembnAkpqDkn49uH
         v9l/GVuBqHOiWAaDyHkQwufaPBoM5xjcrFGYT8FAu7uY1l2pjUdvhK0ZgtYwgP78lcZ9
         TCeRFjGlj35E9KUBNRJFsqhFoL1i/A9D3mSJAl1WQ3YLU41axgwYzre+i8MMVls2LZdP
         tm9iQoliJbo5dF58XaLxExEWFAvxAhjwN5E3hWcy+OE4voAkcW3A6lfxcsWj77DLNYqP
         i8sA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukezEmBl5OAGX/iKZH1qcOoq59azKf+WBY4woD7TPZe0327gM/Ok
	Ivn16VpBllO11wVMTG4exysqd3dW0DiKnuXJgWLuH2xniENNRxe5kX2auhVmgnNoLPapvnbrYzO
	zEsxyDoBNntmfEERVPFg8u54KXxEZ+D95nsJ+hgCsTHpy0RsCPZktS7SuJP9imVOA5A==
X-Received: by 2002:aca:cc15:: with SMTP id c21mr10539408oig.208.1548808933438;
        Tue, 29 Jan 2019 16:42:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6uaPr2bd0b/DOfbWSvcqLt//iReFPQk7bob1+iQWblaoCOqSzEcg0/dM/Lr4KT0nAxAtNA
X-Received: by 2002:aca:cc15:: with SMTP id c21mr10539390oig.208.1548808932765;
        Tue, 29 Jan 2019 16:42:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548808932; cv=none;
        d=google.com; s=arc-20160816;
        b=mWDuAxN0G0ABZGRfdmUEVvakRYo54699wfmoZYjzUmBqB/8nN09kFiLKw0ee0NtJEU
         PRrab5uUvfBKcwB5zStxjmBkRHT+VMgMD//JL7nwMXwzE8PZGYWZWua5C0w3U8rDTp8c
         aGySVl4NknuE6VlPpOZVpSiRvxA2WlTqcY1kHuTk5tBzpJVXx5eyaa52j0bh6N3fFoH3
         GmqaA3duTPz5GBJDuKz1T6avO8NU76DIsjvBZmni6UmibHN/1pnGne6cIrx8nIW7D0wn
         rCoMqWnaCV+6Fq8YGSo2gb/g8DFhMLjSUus6mv/PUK/a8zMg35mQJPmzp/oC1FHI8BSq
         s44g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:date:mime-version
         :cc:to:from:subject:message-id;
        bh=7xnPD9DL3i0s8BYCf2DaG9QAXv7qVlKoI7Tx04pb5xA=;
        b=Kzs5Tzx8uOl2GcQrrhENsgj7RNl2I3kz7wwvjIwXGVHVdzuQAd/E0+RNLTxYPEEIWu
         7xAMDpD7BQNzHWmif76g/D+HN0X4q+cUZSxGuvdL2gWOp6W1CuiWmnTsPhbJqPMO9o5z
         vVqKro8345wLn1h8jmilpu6Cba7u/Euv4VHmssxMB7D0MAF3sYsAu5KvvWqAUTpamAYT
         uq6PEaQFhbb9WGI6t/JjWMBPAm+v8i6xXsJuxnXl8h3m8rTWGK+fElO/Zc9Hw+0a+rwy
         eXXSBgns0dExC6MjqtEU1rU8QNuACQKMdQTzrkjBi1rvxjEkq3JVuCV8/uFrk1+M8ulN
         OxYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l108si6814986otc.109.2019.01.29.16.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 16:42:12 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav108.sakura.ne.jp (fsav108.sakura.ne.jp [27.133.134.235])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0U0g7Hi085879;
	Wed, 30 Jan 2019 09:42:07 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav108.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav108.sakura.ne.jp);
 Wed, 30 Jan 2019 09:42:07 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav108.sakura.ne.jp)
Received: from www262.sakura.ne.jp (localhost [127.0.0.1])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0U0g66Q085875;
	Wed, 30 Jan 2019 09:42:06 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: (from i-love@localhost)
	by www262.sakura.ne.jp (8.15.2/8.15.2/Submit) id x0U0g6EH085874;
	Wed, 30 Jan 2019 09:42:06 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Message-Id: <201901300042.x0U0g6EH085874@www262.sakura.ne.jp>
X-Authentication-Warning: www262.sakura.ne.jp: i-love set sender to penguin-kernel@i-love.sakura.ne.jp using -f
Subject: Re: [PATCH] mm: fix sleeping function warning in
 =?ISO-2022-JP?B?YWxsb2Nfc3dhcF9pbmZv?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Yang Shi <shy828301@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Jiufei Xue <jiufei.xue@linux.alibaba.com>,
        Linux MM <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com,
        Linus Torvalds <torvalds@linux-foundation.org>
MIME-Version: 1.0
Date: Wed, 30 Jan 2019 09:42:06 +0900
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp> <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
In-Reply-To: <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yang Shi wrote:
> On Tue, Jan 29, 2019 at 1:12 PM Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > On 2019/01/30 4:13, Andrew Morton wrote:
> > > On Tue, 29 Jan 2019 20:43:20 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > >
> > >> On 2019/01/29 16:21, Jiufei Xue wrote:
> > >>> Trinity reports BUG:
> > >>>
> > >>> sleeping function called from invalid context at mm/vmalloc.c:1477
> > >>> in_atomic(): 1, irqs_disabled(): 0, pid: 12269, name: trinity-c1
> > >>>
> > >>> [ 2748.573460] Call Trace:
> > >>> [ 2748.575935]  dump_stack+0x91/0xeb
> > >>> [ 2748.578512]  ___might_sleep+0x21c/0x250
> > >>> [ 2748.581090]  remove_vm_area+0x1d/0x90
> > >>> [ 2748.583637]  __vunmap+0x76/0x100
> > >>> [ 2748.586120]  __se_sys_swapon+0xb9a/0x1220
> > >>> [ 2748.598973]  do_syscall_64+0x60/0x210
> > >>> [ 2748.601439]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > >>>
> > >>> This is triggered by calling kvfree() inside spinlock() section in
> > >>> function alloc_swap_info().
> > >>> Fix this by moving the kvfree() after spin_unlock().
> > >>>
> > >>
> > >> Excuse me? But isn't kvfree() safe to be called with spinlock held?
> > >
> > > Yes, I'm having trouble spotting where kvfree() can sleep.  Perhaps it
> > > *used* to sleep on mutex_lock(vmap_purge_lock), but
> > > try_purge_vmap_area_lazy() is using mutex_trylock().  Confused.
> > >
> > > kvfree() darn well *shouldn't* sleep!
> > >
> >
> > If I recall correctly, there was an attempt to allow vfree() to sleep
> > but that attempt failed, and the change to allow vfree() to sleep was
> > reverted. Thus, vfree() had been "Context: Any context except NMI.".

That attempt was not reverted. Instead vfree_atomic() was added.

> >
> > If we want to allow vfree() to sleep, at least we need to test with
> > kvmalloc() == vmalloc() (i.e. force kvmalloc()/kvfree() users to use
> > vmalloc()/vfree() path). For now, reverting the
> > "Context: Either preemptible task context or not-NMI interrupt." change
> > will be needed for stable kernels.
> 
> So, the comment for vfree "May sleep if called *not* from interrupt
> context." is wrong?

Commit bf22e37a641327e3 ("mm: add vfree_atomic()") says

    We are going to use sleeping lock for freeing vmap.  However some
    vfree() users want to free memory from atomic (but not from interrupt)
    context.  For this we add vfree_atomic() - deferred variation of vfree()
    which can be used in any atomic context (except NMIs).

and commit 52414d3302577bb6 ("kvfree(): fix misleading comment") made

    - * Context: Any context except NMI.
    + * Context: Either preemptible task context or not-NMI interrupt.

change. But I think that we converted kmalloc() to kvmalloc() without checking
context of kvfree() callers. Therefore, I think that kvfree() needs to use
vfree_atomic() rather than just saying "vfree() might sleep if called not in
interrupt context."...

