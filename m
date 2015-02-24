Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 495FA6B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:09:33 -0500 (EST)
Received: by wesw62 with SMTP id w62so23468956wes.9
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 00:09:32 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id p8si66155556wjy.134.2015.02.24.00.09.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 00:09:31 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id h11so23118386wiw.1
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 00:09:30 -0800 (PST)
Date: Tue, 24 Feb 2015 09:09:27 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 0/7] Kernel huge I/O mapping support
Message-ID: <20150224080927.GB19069@gmail.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
 <20150223122224.c55554325cc4dadeca067234@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150223122224.c55554325cc4dadeca067234@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com


* Andrew Morton <akpm@linux-foundation.org> wrote:

> <reads the code>
> 
> Oh.  We don't do any checking at all.  We're just telling 
> userspace programmers "don't do that".  hrm.  What are 
> your thoughts on adding the overlap checks to the kernel?

I have requested such sanity checking in previous review as 
well, it has to be made fool-proof for this optimization to 
be usable.

Another alternative would be to make this not a transparent 
optimization, but a separate API: ioremap_hugepage() or so.

The devices and drivers dealing with GBs of remapped pages 
is still relatively low, so they could make explicit use of 
the API and opt in to it.

What I was arguing against was to make it a CONFIG_ option: 
that achieves very little in practice, such APIs should be 
uniformly available.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
