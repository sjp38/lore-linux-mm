Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C98D16B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 10:43:42 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 107so9377715wra.7
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 07:43:42 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s11si13565416wrf.345.2017.11.13.07.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 07:43:40 -0800 (PST)
Date: Mon, 13 Nov 2017 16:43:26 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
In-Reply-To: <20171107130539.52676-1-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1711131642370.1851@nanos>
References: <20171107130539.52676-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 7 Nov 2017, Kirill A. Shutemov wrote:

> In case of 5-level paging, we don't put any mapping above 47-bit, unless
> userspace explicitly asked for it.
> 
> Userspace can ask for allocation from full address space by specifying
> hint address above 47-bit.
> 
> Nicholas noticed that current implementation violates this interface:
> we can get vma partly in high addresses if we ask for a mapping at very
> end of 47-bit address space.
> 
> Let's make sure that, when consider hint address for non-MAP_FIXED
> mapping, start and end of resulting vma are on the same side of 47-bit
> border.

What happens for mappings with MAP_FIXED which cross the border?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
