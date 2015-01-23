Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A039E6B006E
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 07:35:11 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id r20so2475286wiv.4
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 04:35:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si2248885wib.46.2015.01.23.04.35.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 04:35:10 -0800 (PST)
Message-ID: <54C23FFB.5010800@suse.cz>
Date: Fri, 23 Jan 2015 13:35:07 +0100
From: Michal Marek <mmarek@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v9 01/17] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com> <1421859105-25253-2-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1421859105-25253-2-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, open@kvack.org, list@kvack.org, DOCUMENTATION <linux-doc@vger.kernel.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On 2015-01-21 17:51, Andrey Ryabinin wrote:
> +ifdef CONFIG_KASAN_INLINE
> +	call_threshold := 10000
> +else
> +	call_threshold := 0
> +endif

Can you please move this to a Kconfig helper like you did with
CONFIG_KASAN_SHADOW_OFFSET? Despite occasional efforts to reduce the
size of the main Makefile, it has been growing over time. With this
patch set, we are approaching 2.6.28's record of 1669 lines.

Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
