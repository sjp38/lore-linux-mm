Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 13B0C6B0071
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 08:07:19 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so345489pdj.19
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 05:07:18 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id fu1si9761455pbc.344.2014.01.22.05.07.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 05:07:17 -0800 (PST)
Message-ID: <52DFC1BA.8030001@huawei.com>
Date: Wed, 22 Jan 2014 21:03:54 +0800
From: Wang Nan <wangnan0@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] ARM: kexec: copying code to ioremapped area
References: <1390389916-8711-1-git-send-email-wangnan0@huawei.com>	<1390389916-8711-3-git-send-email-wangnan0@huawei.com> <CANacCWz2DdLvns9htszpwWnASrYGXQt+tHMsw4aBbjoyw-DmeQ@mail.gmail.com>
In-Reply-To: <CANacCWz2DdLvns9htszpwWnASrYGXQt+tHMsw4aBbjoyw-DmeQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaibhav Bedia <vaibhav.bedia@gmail.com>
Cc: kexec@lists.infradead.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Geng Hui <hui.geng@huawei.com>, linux-mm@kvack.org, Eric Biederman <ebiederm@xmission.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linux ARM Kernel List <linux-arm-kernel@lists.infradead.org>

On 2014/1/22 20:56, Vaibhav Bedia wrote:
> On Wed, Jan 22, 2014 at 6:25 AM, Wang Nan <wangnan0@huawei.com <mailto:wangnan0@huawei.com>> wrote:
> 
>     ARM's kdump is actually corrupted (at least for omap4460), mainly because of
>     cache problem: flush_icache_range can't reliably ensure the copied data
>     correctly goes into RAM. After mmu turned off and jump to the trampoline, kexec
>     always failed due to random undef instructions.
> 
>     This patch use ioremap to make sure the destnation of all memcpy() is
>     uncachable memory, including copying of target kernel and trampoline.
> 
> 
> AFAIK ioremap on RAM in forbidden in ARM and device memory that ioremap()
> ends up creating is not meant for executable code.
> 
> Doesn't this trigger the WARN_ON() in _arm_ioremap_pfn_caller)?

This patch is depend on the previous one:

ARM: Premit ioremap() to map reserved pages

However, Russell is opposed to it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
