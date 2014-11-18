Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 65FF26B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 11:39:30 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id wn1so4299033obc.3
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 08:39:30 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m38si6872878oik.13.2014.11.18.08.39.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 08:39:29 -0800 (PST)
Message-ID: <546B74F5.10004@oracle.com>
Date: Tue, 18 Nov 2014 11:33:57 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/7] Replace _PAGE_NUMA with PAGE_NONE protections
References: <1415971986-16143-1-git-send-email-mgorman@suse.de> <5466C8A5.3000402@oracle.com> <20141118154246.GB2725@suse.de>
In-Reply-To: <20141118154246.GB2725@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/18/2014 10:42 AM, Mel Gorman wrote:
> 1. I'm assuming this is a KVM setup but can you confirm?

Yes.

> 2. Are you using numa=fake=N?

Yes. numa=fake=24, which is probably way more nodes on any physical machine
than the new code was tested on?

> 3. If you are using fake NUMA, what happens if you boot without it as
>    that should make the patches a no-op?

Nope, still seeing it without fake numa.

> 4. Similarly, does the kernel boot properly without without patches?

Yes, the kernel works fine without the patches both with and without fake
numa.

> 5. Are any other patches applied because the line numbers are not lining
>    up exactly?

I have quite a few more patches on top of next, but they're debug patches
that add VM_BUG_ONs in quite a few places.

One thing that was odd is that your patches had merge conflicts when applied
on -next in mm/huge-memory.c, so maybe that's where line number differences
are coming from.

> 6. As my own KVM setup appears broken, can you tell me if the host
>    kernel has changed recently? If so, does using an older host kernel
>    make a difference?

Nope, I've been using the same host kernel (Ubuntu's 3.16.0-24-generic #32)
for a while now.

> At the moment I'm scratching my head trying to figure out how the
> patches could break 9p like this as I don't believe KVM is doing any
> tricks with the same bits that could result in loss.

This issue reproduces rather easily, I'd be happy to try out debug patches
rather than having you guess at what might have gone wrong.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
