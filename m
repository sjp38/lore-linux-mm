Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F06766B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:57:16 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so1506934pad.21
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 14:57:16 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id hi9si2967329pac.72.2014.08.27.14.57.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 14:57:15 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so1497661pad.8
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 14:57:15 -0700 (PDT)
Date: Wed, 27 Aug 2014 14:55:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v5] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
In-Reply-To: <20140826064952.GR25918@moon>
Message-ID: <alpine.LSU.2.11.1408271443290.7961@eggly.anvils>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com> <1408937681-1472-1-git-send-email-pfeiner@google.com> <alpine.LSU.2.11.1408252142380.2073@eggly.anvils> <20140826064952.GR25918@moon>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

On Tue, 26 Aug 2014, Cyrill Gorcunov wrote:
> On Mon, Aug 25, 2014 at 09:45:34PM -0700, Hugh Dickins wrote:
> > 
> > Hmm.  For a long time I thought you were fixing another important bug
> > with down_write, since we "always" use down_write to modify vm_flags.
> > 
> > But now I'm realizing that if this is the _only_ place which modifies
> > vm_flags with down_read, then it's "probably" safe.  I've a vague
> > feeling that this was discussed before - is that so, Cyrill?
> 
> Well, as far as I remember we were not talking before about vm_flags
> and read-lock in this function, maybe it was on some unrelated lkml thread
> without me CC'ed? Until I miss something obvious using read-lock here
> for vm_flags modification should be safe, since the only thing which is
> important (in context of vma-softdirty) is the vma's presence. Hugh,
> mind to refresh my memory, how long ago the discussion took place?

Sorry for making you think you were losing your mind, Cyrill.

I myself have no recollection of any such conversation with you;
but afraid that I might have lost _my_ memory of it - I didn't want
to get too strident about how fragile (though probably not yet buggy)
this down_read-for-updating-VM_SOFTDIRTY-onlyi is, if there had already
been such a discussion, coming to the conclusion that it is okay for now.

I am fairly sure that I have had some such discussion before; but
probably with someone else, probably still about mmap_sem and vm_flags,
but probably some other VM_flag: the surprising realization that it may
be safe but fragile to use just down_read for updating one particular flag.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
