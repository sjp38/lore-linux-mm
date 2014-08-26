Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id CFF796B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 11:44:05 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so14927826wes.29
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 08:44:05 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.228])
        by mx.google.com with ESMTP id kr8si4500629wjc.94.2014.08.26.08.44.04
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 08:44:04 -0700 (PDT)
Date: Tue, 26 Aug 2014 18:43:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140826154355.GA11464@node.dhcp.inet.fi>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408937681-1472-1-git-send-email-pfeiner@google.com>
 <alpine.LSU.2.11.1408252142380.2073@eggly.anvils>
 <20140826064952.GR25918@moon>
 <20140826140419.GA10625@node.dhcp.inet.fi>
 <20140826141914.GA8952@moon>
 <20140826145612.GA11226@node.dhcp.inet.fi>
 <20140826151813.GB8952@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140826151813.GB8952@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

On Tue, Aug 26, 2014 at 07:18:13PM +0400, Cyrill Gorcunov wrote:
> > Basically, it's safe if only soft-dirty is allowed to modify vm_flags
> > without down_write(). But why is soft-dirty so special?
> 
> because how we use this bit, i mean in normal workload this bit won't
> be used intensively i think so it's not widespread in kernel code

Weak argument to me.

What about walk through vmas twice: first with down_write() to modify
vm_flags and vm_page_prot, then downgrade_write() and do
walk_page_range() on every vma?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
