Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 420736B003B
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 05:03:54 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so8359074pdi.13
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 02:03:53 -0700 (PDT)
Received: by mail-la0-f43.google.com with SMTP id ep20so6593424lab.16
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 02:03:50 -0700 (PDT)
Date: Tue, 8 Oct 2013 13:03:49 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/2 v2] smaps: show VM_SOFTDIRTY flag in VmFlags line
Message-ID: <20131008090349.GB31343@moon>
References: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5252B56C.8030903@parallels.com>
 <1381155304-2ro6e10t-mutt-n-horiguchi@ah.jp.nec.com>
 <20131007175125.7bb300853d37b6a64eba248d@linux-foundation.org>
 <20131008085901.GN6036@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131008085901.GN6036@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org

On Tue, Oct 08, 2013 at 12:59:01PM +0400, Cyrill Gorcunov wrote:
> On Mon, Oct 07, 2013 at 05:51:25PM -0700, Andrew Morton wrote:
> > 
> > Documentation/filesystems/proc.txt needs updating, please.
> 
> I'll do this today.

Ouch, it seems I've missed the reply and Naoya already has it done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
