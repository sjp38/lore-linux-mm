Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3315A6B0069
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 12:48:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 199so6634170pgc.11
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 09:48:03 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 33si8908827plh.804.2018.01.08.09.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 09:48:02 -0800 (PST)
Date: Mon, 8 Jan 2018 20:46:53 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mike Galbraith <efault@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org

On Mon, Jan 08, 2018 at 04:04:44PM +0000, Ingo Molnar wrote:
> 
> hi Kirill,
> 
> As Mike reported it below, your 5-level paging related upstream commit 
> 83e3c48729d9 and all its followup fixes:
> 
>  83e3c48729d9: mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y
>  629a359bdb0e: mm/sparsemem: Fix ARM64 boot crash when CONFIG_SPARSEMEM_EXTREME=y
>  d09cfbbfa0f7: mm/sparse.c: wrong allocation for mem_section
> 
> ... still breaks kexec - and that now regresses -stable as well.
> 
> Given that 5-level paging now syntactically depends on having this commit, if we 
> fully revert this then we'll have to disable 5-level paging as well.

Urghh.. Sorry about this.

I'm on vacation right now. Give me a day to sort this out.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
