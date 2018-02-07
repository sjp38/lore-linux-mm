Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F37ED6B0331
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 11:25:21 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 30so807934wrw.6
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 08:25:21 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 91si1452089wrn.294.2018.02.07.08.25.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Feb 2018 08:25:20 -0800 (PST)
Date: Wed, 7 Feb 2018 17:25:07 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 0/3] x86: Patchable constants
Message-ID: <20180207162507.GB25219@hirez.programming.kicks-ass.net>
References: <20180207145913.2703-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207145913.2703-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 07, 2018 at 05:59:10PM +0300, Kirill A. Shutemov wrote:
> This conversion makes GCC generate worse code. Conversion __PHYSICAL_MASK
> to a patchable constant adds about 5k in .text on defconfig and makes it
> slightly slower at runtime (~0.2% on my box).

Do you have explicit examples for the worse code? That might give clue
on how to improve things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
