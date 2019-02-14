Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 091CEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:21:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1EE521B68
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:21:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="RESrQMJe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1EE521B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C0248E0002; Thu, 14 Feb 2019 14:21:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46E638E0001; Thu, 14 Feb 2019 14:21:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35DA68E0002; Thu, 14 Feb 2019 14:21:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 071A58E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:21:48 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id l125so2883246vkb.22
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:21:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EYnY5U1qbe2Qu78gmzvCa6p4DXVx9bpODLoxRD/Zxzc=;
        b=l5Nrd58HCSHfiFxa5PIGj0gDKK15mTtMV1tAGzkTpbtT1ND3GAy1surYhe5UUq1q8o
         S0O3m9R+LZoYQO/MBrBIkLoi2MLbaMVsOGBSM+1ScAAgJ6VA3Q87GlYZ70pzdko8AQWc
         YsS5TS/6XCrstc+Z2QT56g2WGRGR5eelOzywLFqkVj+fot9xXzVzKZLBw3y8kwjWNtTf
         T7pvKQWOPAuaFw0M45c9HAQXrxO9J8i/WOQYgmnut3i/Hd/mb6FMiUtWDpn7MAMEViPe
         +h1lRD6kzOM2U/E1KyX00z0kGGqAAOHikr0eahobT9+N+amd0+oE2zIGmAUJdT7LBywu
         geNA==
X-Gm-Message-State: AHQUAua27LbnTcQGDz5E6ryOBvGWS5bD9X71G+Q8qrh5HgopspU+GOoH
	3kNKurQM5Id1WQWQ6cN+3zo0BrBUytMMxyjK3AIKF3iQuAYPxjRXskwomfyBRunhnemOPGqWW3D
	YIB1yA4TYMJiGS5XlCDRr+dFGuFBEQcE9WrWPUXNHUQSzOHPGyQP/QqWGYc9Cpfu6LbjjjyTBCT
	X/2c1MF53pZmM/2zi0ZpP/+GqBuEfMwwWWtofD4j/9XKbLPyNhyxgdmK0oTq2YegNYK2QLIjHqq
	xuuyxBQBeFjs/V74kLfJujOo9R4ewb2qw1GQxwfWmKPu+BvdTrvbCQrcJmSftm5IeE+wFppzxFq
	vTpLT+I89GFjqd+A5K8xliLvHYFjTUlFxDgtkWZUTjzRVTprNjvaqHSdI0zZkZoh4TQgt6o6dUt
	M
X-Received: by 2002:a67:81c1:: with SMTP id c184mr2886105vsd.111.1550172107571;
        Thu, 14 Feb 2019 11:21:47 -0800 (PST)
X-Received: by 2002:a67:81c1:: with SMTP id c184mr2886062vsd.111.1550172106449;
        Thu, 14 Feb 2019 11:21:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550172106; cv=none;
        d=google.com; s=arc-20160816;
        b=Kk92r33B5pxT5tpBdT7UN3MI+QGcFFjT3eSf/Z/sSFmq8EKT3aW3Jrzj9qXlTbEDva
         RTo50jLJP9M77rOgFP8L/+TZ/oDch3At5m1e8jVFEIWFhtUg4wmMyLD/55C8o+7KaRbh
         dpGudboNC4CwNLqf72toVni7IXsCVkkP1ZhGUygJzr73lWmtsuESduDEVz50MsFIWagd
         07/1NppV/IfvsycIztXA2NuUEhEwZjlAx/2EgKj60y6ztP5vU1Sm/LUbkGDmMAbOl8cY
         eSCWdUXl6belulIzcwWuP0DsnSYsWiqtsfDQao5IGt3cM1214wNg3CGK68GrM8IRuXW0
         ircw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EYnY5U1qbe2Qu78gmzvCa6p4DXVx9bpODLoxRD/Zxzc=;
        b=rUlHvEDTDbgjfnYgOYdZ982aKImf54zd+zJ3XDAjTTsPQ+SnE8fXMJDP9PKjkxnrZX
         2flTVIJNVW7CXbTO1K5wVyKOwD32ahV6dsicILA0PvTVAiTGLTpZSqVUTeApR9AoC2gD
         qDItlYrO/fMx9aPcI7qBWwfdfL5oGHrHO9pXWx+s6LosFIKEMmZQ2Beisw2KjXcwwjAs
         7++rVt+hV63sDeKKNZwFtOxvz+HQ0IscFfdL+8UKyLeYBfkoZGiT2zTGDVq+V7jFjJfb
         W11Z7EvGZzXaF6L5GBOWIj9is3k0h/6jyUOke5EWXedL0LG2RhHTWixFJN1EmLUZ6Upc
         t5rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=RESrQMJe;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p140sor1753902vkd.3.2019.02.14.11.21.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 11:21:46 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=RESrQMJe;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EYnY5U1qbe2Qu78gmzvCa6p4DXVx9bpODLoxRD/Zxzc=;
        b=RESrQMJebeLQ9Dw9ZXWxeLDAynNFPdoe0IGwY0YdCVwPF30BVFZZQ7gGmi+rp90TqS
         KJaXFKnQVIeWgT7poV2TrDxMvJSMIAAUxB2xmgoNnWRKieOZyu1uO0JlNujZw+OGm7Tb
         2cDwDr3WeefemnbkIAuOmfeSAAJ/mvSQu+85U=
X-Google-Smtp-Source: AHgI3IYnOZlHsveWCJVLc9UFeM28pxC+12RoMYSVrYOFKZyC4rtpAn0HFVkgEZxq8qku93Sq/HNabQ==
X-Received: by 2002:a1f:dac5:: with SMTP id r188mr2881484vkg.19.1550172105483;
        Thu, 14 Feb 2019 11:21:45 -0800 (PST)
Received: from mail-ua1-f53.google.com (mail-ua1-f53.google.com. [209.85.222.53])
        by smtp.gmail.com with ESMTPSA id g65sm683185vke.31.2019.02.14.11.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 11:21:44 -0800 (PST)
Received: by mail-ua1-f53.google.com with SMTP id v26so2411777uap.4
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:21:44 -0800 (PST)
X-Received: by 2002:a9f:2709:: with SMTP id a9mr2856760uaa.10.1550172103728;
 Thu, 14 Feb 2019 11:21:43 -0800 (PST)
MIME-Version: 1.0
References: <20190207072421.GA9120@rapoport-lnx>
In-Reply-To: <20190207072421.GA9120@rapoport-lnx>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 14 Feb 2019 11:21:30 -0800
X-Gmail-Original-Message-ID: <CAGXu5jKLBYMZ-cHyp4m_9TO1gAF2cQDVKu-XyH4i3aj7MqRCnA@mail.gmail.com>
Message-ID: <CAGXu5jKLBYMZ-cHyp4m_9TO1gAF2cQDVKu-XyH4i3aj7MqRCnA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>, 
	James Bottomley <James.Bottomley@hansenpartnership.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 6, 2019 at 11:24 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> Address space isolation has been used to protect the kernel from the
> userspace and userspace programs from each other since the invention of
> the virtual memory.

Well, traditionally the kernel's protection has been one-sided: we've
left userspace mapped while in the kernel, which has lead to countless
exploits. SMEP/SMAP (or similar for other architectures, like ARM's
PXN/PAN) have finally mitigated that, but we're still left with a lot
of older machines (and other architectures) that would benefit from
unmapping the userspace while in the kernel.

> Assuming that kernel bugs and therefore vulnerabilities are inevitable
> it might be worth isolating parts of the kernel to minimize damage
> that these vulnerabilities can cause.

Yes please. :) Two cases jump to mind:

1) Make regions unwritable to avoid write-anywhere data modification
attacks. For code and rodata, this is already done with regular page
table bits making them read-only for the entire lifetime of the
kernel. For areas that need writing but are sensitive (e.g. the page
tables themselves, and generally function pointer tables), there needs
to be a way to keep modifications isolated to given code (to block
write-anywhere attacks), keeping them read-only through all other
accesses. This is could be done with per-CPU page tables, a faster
version of the "write rarely" patch set[1], or maybe with the kernel
text poking (mentioned in your email). Attacking the page tables
directly is now the common way to gain execute control on the kernel,
since so much of the rest of memory is locked down[2]. How can we keep
page tables read-only except for when the page table code needs to
write to them?

2) Make a region unreadable to avoid read-anywhere memory disclosure
attacks. This mean it's either unmapped (for both data and code cases)
or we gain execute-not-read hardware bits (for code cases). Unmapping
code means a reduction in ROP gadgets, unmapping data means reduction
in memory disclosure surface. Note that while both coarse (CET) and
fine-grain (function-prototype-checking) CFI vastly reduces the
availability of ROP gadgets, the kernel still has a lot of functions
that return void and take a single unsigned long, so anything to
remove more code from visibility is good.

> There is already ongoing work in a similar direction, like XPFO [1] and
> temporary mappings proposed for the kernel text poking [2].
>
> We have several vague ideas how we can take this even further and make
> different parts of kernel run in different address spaces:
> * Remove most of the kernel mappings from the syscall entry and add a
>   trampoline when the syscall processing needs to call the "core
>   kernel".

Defining this boundary may be very tricky, but maybe the same logic
used for CFI and function graph analysis could be used to find the
existing bright lines between code regions...

> * Make the parts of the kernel that execute in a namespace use their
>   own mappings for the namespace private data
> * Extend EXPORT_SYMBOL to include a trampoline so that the code
>   running in modules won't map the entire kernel
> * Execute BFP programs in a dedicated address space

Pushing drivers into isolated regions would be very interesting. If it
needs context-switching, though, we're headed to microkernel fun.

> These are very general possible directions. We are exploring some of
> them now to understand if the security value is worth the complexity
> and the performance impact.
>
> We believe it would be helpful to discuss the general idea of address
> space isolation inside the kernel, both from the technical aspect of
> how it can be achieved simply and efficiently and from the isolation
> aspect of what actual security guarantees it usefully provides.
>
> [1] https://lore.kernel.org/lkml/cover.1547153058.git.khalid.aziz@oracle.com/
> [2] https://lore.kernel.org/lkml/20190129003422.9328-4-rick.p.edgecombe@intel.com/

I won't be able to make it to the conference, but I'm very interested
in finding ways forward on this topic. :)

-Kees

[1] https://patchwork.kernel.org/project/kernel-hardening/list/?series=79855
[2] https://www.blackhat.com/docs/asia-18/asia-18-WANG-KSMA-Breaking-Android-kernel-isolation-and-Rooting-with-ARM-MMU-features.pdf

-- 
Kees Cook

