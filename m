Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 962806B012C
	for <linux-mm@kvack.org>; Tue, 26 May 2015 05:51:48 -0400 (EDT)
Received: by wghq2 with SMTP id q2so91946074wgh.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 02:51:48 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id k5si17217610wix.79.2015.05.26.02.51.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 02:51:46 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Date: Tue, 26 May 2015 11:51:17 +0200
Message-ID: <3076059.95sGQMhV87@wuerfel>
In-Reply-To: <1CD6E4BA-95AF-420C-8270-6AAF783B6F60@foss.arm.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <5601369.jDWtB6nFJC@wuerfel> <1CD6E4BA-95AF-420C-8270-6AAF783B6F60@foss.arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@foss.arm.com>
Cc: Jungseok Lee <jungseoklee85@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, "barami97@gmail.com" <barami97@gmail.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tuesday 26 May 2015 01:36:29 Catalin Marinas wrote:
> 
> > There are a lot of workloads that would benefit from having lower
> > per-thread memory cost.
> 
> If we keep the 16KB stack, is there any advantage in a separate IRQ one (assuming 
> that we won't overflow 16KB)?

It makes possible errors more reproducible: we already know that we need over
8kb for normal stacks based on Minchan's findings, and the chance that an interrupt
happens at a time when the stack is the highest is very low, but that just makes
the bug much harder to find if you ever run into it.

If we overflow the stack (independent of its size) with a process stack by itself,
it will always happen in the same call chain, not a combination of a call chain
an a particularly bad interrupt.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
