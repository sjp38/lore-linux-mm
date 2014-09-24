Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9B22C6B0055
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 17:59:29 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so9565233pad.13
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 14:59:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fr3si640979pbd.34.2014.09.24.14.59.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 14:59:28 -0700 (PDT)
Date: Wed, 24 Sep 2014 14:59:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: softdirty: keep bit when zapping file pte
Message-Id: <20140924145927.04e8eb7ba6c1410a797293c7@linux-foundation.org>
In-Reply-To: <1411200187-40896-1-git-send-email-pfeiner@google.com>
References: <1411200187-40896-1-git-send-email-pfeiner@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Feiner <pfeiner@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>

On Sat, 20 Sep 2014 01:03:07 -0700 Peter Feiner <pfeiner@google.com> wrote:

> Fixes the same bug as b43790eedd31e9535b89bbfa45793919e9504c34 and
> 9aed8614af5a05cdaa32a0b78b0f1a424754a958 where the return value of
> pte_*mksoft_dirty was being ignored.
> 
> To be sure that no other pte/pmd "mk" function return values were
> being ignored, I annotated the functions in
> arch/x86/include/asm/pgtable.h with __must_check and rebuilt.
> 

Grumble.

It is useful to identify preceding similar patches but that isn't a
good way of describing *this* patch.  What is wrong with the current
code, how does the patch fix it.

And, particularly, what do you think are the end-user visible effects
of the bug?  This info helps people to work out which kernel versions
need the fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
