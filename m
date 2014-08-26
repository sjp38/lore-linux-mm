Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id D1CDD6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 11:53:54 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id gl10so15022411lab.21
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 08:53:54 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id od10si4096482lbc.20.2014.08.26.08.53.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Aug 2014 08:53:53 -0700 (PDT)
Received: by mail-la0-f50.google.com with SMTP id pi18so15119726lab.23
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 08:53:52 -0700 (PDT)
Date: Tue, 26 Aug 2014 19:53:51 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140826155351.GC8952@moon>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408937681-1472-1-git-send-email-pfeiner@google.com>
 <alpine.LSU.2.11.1408252142380.2073@eggly.anvils>
 <20140826064952.GR25918@moon>
 <20140826140419.GA10625@node.dhcp.inet.fi>
 <20140826141914.GA8952@moon>
 <20140826145612.GA11226@node.dhcp.inet.fi>
 <20140826151813.GB8952@moon>
 <20140826154355.GA11464@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140826154355.GA11464@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

On Tue, Aug 26, 2014 at 06:43:55PM +0300, Kirill A. Shutemov wrote:
> On Tue, Aug 26, 2014 at 07:18:13PM +0400, Cyrill Gorcunov wrote:
> > > Basically, it's safe if only soft-dirty is allowed to modify vm_flags
> > > without down_write(). But why is soft-dirty so special?
> > 
> > because how we use this bit, i mean in normal workload this bit won't
> > be used intensively i think so it's not widespread in kernel code
> 
> Weak argument to me.
> 
> What about walk through vmas twice: first with down_write() to modify
> vm_flags and vm_page_prot, then downgrade_write() and do
> walk_page_range() on every vma?

I still it's undeeded, but for sure using write-lock/downgrade won't hurt,
so no argues from my side.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
