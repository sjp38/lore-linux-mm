Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF126B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 10:19:17 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id u10so1448269lbd.32
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 07:19:16 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id le2si3644183lac.114.2014.08.26.07.19.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Aug 2014 07:19:15 -0700 (PDT)
Received: by mail-la0-f44.google.com with SMTP id el20so15112958lab.17
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 07:19:15 -0700 (PDT)
Date: Tue, 26 Aug 2014 18:19:14 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140826141914.GA8952@moon>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408937681-1472-1-git-send-email-pfeiner@google.com>
 <alpine.LSU.2.11.1408252142380.2073@eggly.anvils>
 <20140826064952.GR25918@moon>
 <20140826140419.GA10625@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140826140419.GA10625@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

On Tue, Aug 26, 2014 at 05:04:19PM +0300, Kirill A. Shutemov wrote:
> > > 
> > > But now I'm realizing that if this is the _only_ place which modifies
> > > vm_flags with down_read, then it's "probably" safe.  I've a vague
> > > feeling that this was discussed before - is that so, Cyrill?
> > 
> > Well, as far as I remember we were not talking before about vm_flags
> > and read-lock in this function, maybe it was on some unrelated lkml thread
> > without me CC'ed? Until I miss something obvious using read-lock here
> > for vm_flags modification should be safe, since the only thing which is
> > important (in context of vma-softdirty) is the vma's presence. Hugh,
> > mind to refresh my memory, how long ago the discussion took place?
> 
> It seems safe in vma-softdirty context. But if somebody else will decide that
> it's fine to modify vm_flags without down_write (in their context), we
> will get trouble. Sasha will come with weird bug report one day ;)
> 
> At least vm_flags must be updated atomically to avoid race in middle of
> load-modify-store.

Which race you mean here? Two concurrent clear-refs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
