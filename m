Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 293996B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 17:21:38 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so7722166pdj.16
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 14:21:37 -0700 (PDT)
Received: by mail-lb0-f173.google.com with SMTP id o14so6067747lbi.18
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 14:21:34 -0700 (PDT)
Date: Tue, 8 Oct 2013 01:21:33 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/2 v2] smaps: show VM_SOFTDIRTY flag in VmFlags line
Message-ID: <20131007212133.GL6036@moon>
References: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5252B56C.8030903@parallels.com>
 <1381155304-2ro6e10t-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381155304-2ro6e10t-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org

On Mon, Oct 07, 2013 at 10:15:04AM -0400, Naoya Horiguchi wrote:
> > 
> > The comment is not correct. Per-VMA soft-dirty flag means, that
> > VMA is "newly created" one and thus represents a new (dirty) are
> > in task's VM.
> 
> Thanks for the correction. I changed the description.

Looks good to me, thanks!

Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
