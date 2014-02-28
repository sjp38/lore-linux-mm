Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id C8E466B006E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 18:08:23 -0500 (EST)
Received: by mail-vc0-f173.google.com with SMTP id ld13so1410767vcb.4
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 15:08:23 -0800 (PST)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id kl10si1159312vdb.90.2014.02.28.15.08.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 15:08:23 -0800 (PST)
Received: by mail-ve0-f175.google.com with SMTP id oz11so520493veb.6
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 15:08:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140228001039.GB8034@node.dhcp.inet.fi>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+55aFwOe_m3cfQDGxmcBavhyQTqQQNGvACR4YPLaazM_0oyUw@mail.gmail.com>
	<20140228001039.GB8034@node.dhcp.inet.fi>
Date: Fri, 28 Feb 2014 17:08:22 -0600
Message-ID: <CA+55aFyuspw4viBYbjd=j+zOHe1w-_LMCUHdyTjt4yUqUyosdw@mail.gmail.com>
Subject: Re: [PATCHv3 0/2] mm: map few pages around fault address if they are
 in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 27, 2014 at 6:10 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> Also Matthew noticed that some drivers do ugly hacks like fault in whole
> VMA on first page fault. IIUC, it's for performance reasons. See
> psbfb_vm_fault() or ttm_bo_vm_fault().

I guarantee it's not for performance reasons, it's probably some other breakage.

And if anything really does want to populate things fully, doing so at
fault time is wrong anyway, you should just use MAP_POPULATE at mmap
time.

So I'll believe the shm/tmpfs issue, and that's "mm internal" anyway.
But random crappy drivers? No way in hell.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
