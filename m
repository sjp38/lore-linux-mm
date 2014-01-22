Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9155E6B0069
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 07:56:54 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z6so92017yhz.41
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 04:56:54 -0800 (PST)
Received: from mail-qc0-x22d.google.com (mail-qc0-x22d.google.com [2607:f8b0:400d:c01::22d])
        by mx.google.com with ESMTPS id s6si10732707yho.164.2014.01.22.04.56.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 04:56:53 -0800 (PST)
Received: by mail-qc0-f173.google.com with SMTP id i8so379767qcq.18
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 04:56:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1390389916-8711-3-git-send-email-wangnan0@huawei.com>
References: <1390389916-8711-1-git-send-email-wangnan0@huawei.com>
	<1390389916-8711-3-git-send-email-wangnan0@huawei.com>
Date: Wed, 22 Jan 2014 07:56:52 -0500
Message-ID: <CANacCWz2DdLvns9htszpwWnASrYGXQt+tHMsw4aBbjoyw-DmeQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] ARM: kexec: copying code to ioremapped area
From: Vaibhav Bedia <vaibhav.bedia@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c128c6aebd2104f08ea8e1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Nan <wangnan0@huawei.com>
Cc: kexec@lists.infradead.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Geng Hui <hui.geng@huawei.com>, linux-mm@kvack.org, Eric Biederman <ebiederm@xmission.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linux ARM Kernel List <linux-arm-kernel@lists.infradead.org>

--001a11c128c6aebd2104f08ea8e1
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Jan 22, 2014 at 6:25 AM, Wang Nan <wangnan0@huawei.com> wrote:

> ARM's kdump is actually corrupted (at least for omap4460), mainly because
> of
> cache problem: flush_icache_range can't reliably ensure the copied data
> correctly goes into RAM. After mmu turned off and jump to the trampoline,
> kexec
> always failed due to random undef instructions.
>
> This patch use ioremap to make sure the destnation of all memcpy() is
> uncachable memory, including copying of target kernel and trampoline.
>

AFAIK ioremap on RAM in forbidden in ARM and device memory that ioremap()
ends up creating is not meant for executable code.

Doesn't this trigger the WARN_ON() in _arm_ioremap_pfn_caller)?

--001a11c128c6aebd2104f08ea8e1
Content-Type: text/html; charset=ISO-8859-1

<div dir="ltr"><div class="gmail_extra"><div class="gmail_quote">On Wed, Jan 22, 2014 at 6:25 AM, Wang Nan <span dir="ltr">&lt;<a href="mailto:wangnan0@huawei.com" target="_blank">wangnan0@huawei.com</a>&gt;</span> wrote:<br>
<blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">ARM&#39;s kdump is actually corrupted (at least for omap4460), mainly because of<br>
cache problem: flush_icache_range can&#39;t reliably ensure the copied data<br>
correctly goes into RAM. After mmu turned off and jump to the trampoline, kexec<br>
always failed due to random undef instructions.<br>
<br>
This patch use ioremap to make sure the destnation of all memcpy() is<br>
uncachable memory, including copying of target kernel and trampoline.<br></blockquote><div><br></div><div>AFAIK ioremap on RAM in forbidden in ARM and device memory that ioremap()</div><div>ends up creating is not meant for executable code.</div>
<div><br></div><div>Doesn&#39;t this trigger the WARN_ON() in _arm_ioremap_pfn_caller)?</div></div></div></div>

--001a11c128c6aebd2104f08ea8e1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
