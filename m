Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id BDB806B0036
	for <linux-mm@kvack.org>; Sat, 20 Sep 2014 04:08:49 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id gi9so4356948lab.30
        for <linux-mm@kvack.org>; Sat, 20 Sep 2014 01:08:48 -0700 (PDT)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id ci10si5648726lad.27.2014.09.20.01.08.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 20 Sep 2014 01:08:48 -0700 (PDT)
Received: by mail-lb0-f181.google.com with SMTP id z11so4412234lbi.12
        for <linux-mm@kvack.org>; Sat, 20 Sep 2014 01:08:47 -0700 (PDT)
Date: Sat, 20 Sep 2014 12:08:45 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: softdirty: keep bit when zapping file pte
Message-ID: <20140920080845.GX16395@moon>
References: <1411200187-40896-1-git-send-email-pfeiner@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411200187-40896-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Feiner <pfeiner@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Sep 20, 2014 at 01:03:07AM -0700, Peter Feiner wrote:
> Fixes the same bug as b43790eedd31e9535b89bbfa45793919e9504c34 and
> 9aed8614af5a05cdaa32a0b78b0f1a424754a958 where the return value of
> pte_*mksoft_dirty was being ignored.
> 
> To be sure that no other pte/pmd "mk" function return values were
> being ignored, I annotated the functions in
> arch/x86/include/asm/pgtable.h with __must_check and rebuilt.
> 
> Signed-off-by: Peter Feiner <pfeiner@google.com>
Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

I might be missing it, thanks a huge Peter!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
