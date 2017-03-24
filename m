Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A60A86B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:08:33 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u108so6264543wrb.3
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:08:33 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id q78si1904393wmb.122.2017.03.24.02.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 02:08:00 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id n11so7850695wma.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:07:59 -0700 (PDT)
Date: Fri, 24 Mar 2017 12:07:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/6] x86/kasan: Prepare clear_pgds() to switch to
 <asm-generic/pgtable-nop4d.h>
Message-ID: <20170324090757.inkuvayf5t7g73po@node.shutemov.name>
References: <20170317185515.8636-1-kirill.shutemov@linux.intel.com>
 <20170317185515.8636-5-kirill.shutemov@linux.intel.com>
 <218853b4-3498-dab9-d1e9-02caed4d9322@virtuozzo.com>
 <20170322073136.GC13904@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170322073136.GC13904@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

On Wed, Mar 22, 2017 at 08:31:36AM +0100, Ingo Molnar wrote:
> * Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> > On 03/17/2017 09:55 PM, Kirill A. Shutemov wrote:
> > > With folded p4d, pgd_clear() is nop. Change clear_pgds() to use
> > > p4d_clear() instead.
> > > 
> > 
> > You could probably just use set_pgd(pgd_offset_k(start), __pgd(0)); instead of pgd_clear()
> > as we already do in arm64.
> > It's basically pgd_clear() except it's not a nop wih p4d folded.
> 
> Makes sense. Kirill, if you agree, mind spinning a v2 patch?

I can re-spin, if you want. But honestly, I don't think such constructs
help readability.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
