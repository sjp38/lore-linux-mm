Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EBCBC6B03AB
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 10:09:08 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m28so142088103pgn.14
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 07:09:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x3si16969308plb.1.2017.04.11.07.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 07:09:08 -0700 (PDT)
Date: Tue, 11 Apr 2017 07:09:07 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 3/8] x86/boot/64: Add support of additional page table
 level during early boot
Message-ID: <20170411140907.GD4021@tassilo.jf.intel.com>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-4-kirill.shutemov@linux.intel.com>
 <20170411070203.GA14621@gmail.com>
 <20170411105106.4zgbzuu4s4267zyv@node.shutemov.name>
 <20170411112845.GA15212@gmail.com>
 <20170411114616.otx2f6aw5lcvfc2o@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170411114616.otx2f6aw5lcvfc2o@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@amacapital.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> I'll look closer (building proccess it's rather complicated), but my
> understanding is that VDSO is stand-alone binary and doesn't really links
> with the rest of the kernel, rather included as blob, no?
> 
> Andy, may be you have an idea?

There isn't any way I know of to directly link them together. The ELF 
format wasn't designed for that. You would need to merge blobs and then use
manual jump vectors, like the 16bit startup code does. It would be likely
complicated and ugly.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
