Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E84156B0069
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 16:36:29 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so2746151pad.22
        for <linux-mm@kvack.org>; Sat, 18 Oct 2014 13:36:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id kp1si4168197pbd.33.2014.10.18.13.36.28
        for <linux-mm@kvack.org>;
        Sat, 18 Oct 2014 13:36:28 -0700 (PDT)
Date: Sat, 18 Oct 2014 13:22:07 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 04/21] mm: Allow page fault handlers to perform the
 COW
Message-ID: <20141018172207.GN11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-5-git-send-email-matthew.r.wilcox@intel.com>
 <20141016091136.GC19075@thinkos.etherlink>
 <20141016194815.GD11522@wil.cx>
 <289646725.10903.1413560101974.JavaMail.zimbra@efficios.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <289646725.10903.1413560101974.JavaMail.zimbra@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 17, 2014 at 03:35:01PM +0000, Mathieu Desnoyers wrote:
> > > The page fault handler being very much performance sensitive, I'm
> > > wondering if it would not be better to move cow_page near the end of
> > > struct vm_fault, so that the "page" field can stay on the first
> > > cache line.
> 
> Although it's pretty much always true that recent architectures L2 cache
> lines are 64 bytes, I was more thinking about L1 cache lines, which are,
> at least on moderately old Intel Pentium HW, 32 bytes in size (AFAIK
> Pentium II and III).
> 
> It remains to be seen whether we care about performance that much on this
> kind of HW though.

Oh, I just remembered ... this data structure is on the stack, so if it's
not cache-hot, something has gone horribly wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
