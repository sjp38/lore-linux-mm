Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6A36B0037
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 04:59:48 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so8456163pdi.28
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 01:59:47 -0700 (PDT)
Received: by mail-la0-f46.google.com with SMTP id eh20so6612102lab.33
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 01:59:41 -0700 (PDT)
Date: Tue, 8 Oct 2013 12:59:01 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/2 v2] smaps: show VM_SOFTDIRTY flag in VmFlags line
Message-ID: <20131008085901.GN6036@moon>
References: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5252B56C.8030903@parallels.com>
 <1381155304-2ro6e10t-mutt-n-horiguchi@ah.jp.nec.com>
 <20131007175125.7bb300853d37b6a64eba248d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131007175125.7bb300853d37b6a64eba248d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org

On Mon, Oct 07, 2013 at 05:51:25PM -0700, Andrew Morton wrote:
> 
> Documentation/filesystems/proc.txt needs updating, please.

I'll do this today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
