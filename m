Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id DE9B66B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 03:13:09 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id q1so393025lam.18
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 00:13:09 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id lm5si1830146lac.7.2014.09.25.00.13.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 00:13:08 -0700 (PDT)
Received: by mail-lb0-f171.google.com with SMTP id l4so11969237lbv.2
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 00:13:07 -0700 (PDT)
Date: Thu, 25 Sep 2014 10:30:06 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: softdirty: keep bit when zapping file pte
Message-ID: <20140925063006.GN2227@moon>
References: <1411200187-40896-1-git-send-email-pfeiner@google.com>
 <20140924145927.04e8eb7ba6c1410a797293c7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140924145927.04e8eb7ba6c1410a797293c7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>

On Wed, Sep 24, 2014 at 02:59:27PM -0700, Andrew Morton wrote:
> On Sat, 20 Sep 2014 01:03:07 -0700 Peter Feiner <pfeiner@google.com> wrote:
> 
> > Fixes the same bug as b43790eedd31e9535b89bbfa45793919e9504c34 and
> > 9aed8614af5a05cdaa32a0b78b0f1a424754a958 where the return value of
> > pte_*mksoft_dirty was being ignored.
> > 
> > To be sure that no other pte/pmd "mk" function return values were
> > being ignored, I annotated the functions in
> > arch/x86/include/asm/pgtable.h with __must_check and rebuilt.
> > 
> 
> Grumble.
> 
> It is useful to identify preceding similar patches but that isn't a
> good way of describing *this* patch.  What is wrong with the current
> code, how does the patch fix it.

The userspace effect is that without this patch softdirty mark might be lost
if file mapped pte get zapped. It should go into @stable series after 3.12.

> 
> And, particularly, what do you think are the end-user visible effects
> of the bug?  This info helps people to work out which kernel versions
> need the fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
