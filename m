Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45BC46B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:42:08 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j92so256653576ioi.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:42:08 -0800 (PST)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id c134si41297262ioe.243.2016.11.28.09.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 09:42:07 -0800 (PST)
Received: by mail-io0-x242.google.com with SMTP id r94so24052905ioe.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:42:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <31b1393c-22d2-8a49-842c-9678a1921441@intel.com>
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com> <20161128083715.GA21738@aaronlu.sh.intel.com>
 <20161128084012.GC21738@aaronlu.sh.intel.com> <31b1393c-22d2-8a49-842c-9678a1921441@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 28 Nov 2016 09:42:07 -0800
Message-ID: <CA+55aFy_qBh6iz+vH+6QKyLcboRiu8r2b6KY_gxLBTqeJprgNg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mremap: use mmu gather logic for tlb flush in mremap
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Aaron Lu <aaron.lu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Nov 28, 2016 at 9:32 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>
> But, both call-sites are still keeping 'force_flush' to store the
> information about whether we ever saw a dirty pte.  If we moved _that_
> logic into the x86 mmu_gather code, we could get rid of all the
> 'force_flush' tracking in both call sites.  It also makes us a bit more
> future-proof against these page_mkclean() races if we ever grow a third
> site for clearing ptes.

Yeah, that sounds like a nice cleanup and would put all the real state
into that mmu_gather structure.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
