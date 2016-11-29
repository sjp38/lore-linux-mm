Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 979666B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 22:22:16 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so400196652pgc.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 19:22:16 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m29si56812451pgn.94.2016.11.28.19.22.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 19:22:15 -0800 (PST)
Date: Tue, 29 Nov 2016 11:22:12 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH] mremap: move_ptes: check pte dirty after its removal
Message-ID: <20161129032212.GA1727@aaronlu.sh.intel.com>
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com>
 <20161128083715.GA21738@aaronlu.sh.intel.com>
 <20161128084012.GC21738@aaronlu.sh.intel.com>
 <CA+55aFwm8MgLi3pDMOQr2gvmjRKXeSjsmV2kLYSYZHFiUa_0fQ@mail.gmail.com>
 <977b6c8b-2df3-5f4b-0d6c-fe766cf3fae0@intel.com>
 <CA+55aFx_vOfab=WNHd=OR7vng2V_UqrEdx_xZBsKv_ohE65f8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx_vOfab=WNHd=OR7vng2V_UqrEdx_xZBsKv_ohE65f8w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Nov 28, 2016 at 07:06:39PM -0800, Linus Torvalds wrote:
> On Mon, Nov 28, 2016 at 6:57 PM, Aaron Lu <aaron.lu@intel.com> wrote:
> >
> > Here is a fix patch, sorry for the trouble.
> 
> I don't think you tested this one.. You've now essentially reverted
> 5d1904204c99 entirely by making the new force_flush logic a no-op.

Right, I just did a build test.
Now I'm doing more tests, sorry for being careless.

Regards,
Aaron

> 
> > +               pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
> >                 if (pmd_present(*old_pmd) && pmd_dirty(*old_pmd))
> >                         force_flush = true;
> 
> You need to be testing "pmd", not "*old_pmd".
> 
> Because now "*old_pmd" will be zeroes.
> 
> >                 if (pte_present(*old_pte) && pte_dirty(*old_pte))
> >                         force_flush = true;
> 
> Similarly here. You need to check "pte", not "*old_pte".
> 
>             Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
