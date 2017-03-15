Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 603F46B038C
	for <linux-mm@kvack.org>; Sat, 18 Mar 2017 13:01:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h188so8663390wma.4
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 10:01:19 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id i63si7711969wmd.135.2017.03.18.10.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Mar 2017 10:01:17 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id u108so13037934wrb.2
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 10:01:17 -0700 (PDT)
Date: Wed, 15 Mar 2017 18:42:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/6] x86: 5-level paging enabling for v4.12, Part 1
Message-ID: <20170315154205.33hvpvkbjypgkd7g@node.shutemov.name>
References: <20170313143309.16020-1-kirill.shutemov@linux.intel.com>
 <20170314074729.GA23151@gmail.com>
 <CA+55aFzALboaXe5TWv8=3QZBPJCVAVBmfxTjQEi-aAnHKYAuPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzALboaXe5TWv8=3QZBPJCVAVBmfxTjQEi-aAnHKYAuPQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Mar 14, 2017 at 10:48:51AM -0700, Linus Torvalds wrote:
> On Tue, Mar 14, 2017 at 12:47 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > I've also applied the GUP patch, with the assumption that you'll address Linus's
> > request to switch x86 over to the generic version.
> 
> Note that switching over to the generic version is somewhat fraught
> with subtle issues:
> 
>  (a) we need to make sure that x86 actually matches the required
> semantics for the generic GUP.
> 
>  (b) we need to make sure the atomicity of the page table reads is ok.
> 
>  (c) need to verify the maximum VM address properly

There's another difference with generic version: it uses
page_cache_get_speculative() instead of plain get_page() on x86.
That's somewhat more expensive, but probably fine.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
