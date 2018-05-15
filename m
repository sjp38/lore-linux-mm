Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCFE6B0007
	for <linux-mm@kvack.org>; Tue, 15 May 2018 07:48:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a6-v6so2786651pgt.15
        for <linux-mm@kvack.org>; Tue, 15 May 2018 04:48:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d12-v6si9637134pgu.288.2018.05.15.04.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 04:47:59 -0700 (PDT)
Date: Tue, 15 May 2018 13:47:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180515114755.GY12217@hirez.programming.kicks-ass.net>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Tue, May 15, 2018 at 01:43:23PM +0300, Boaz Harrosh wrote:
> Yes I know, but that is exactly the point of this flag. I know that this
> address is only ever accessed from a single core. Because it is an mmap (vma)
> of an O_TMPFILE-exclusive file created in a core-pinned thread and I allow
> only that thread any kind of access to this vma. Both the filehandle and the
> mmaped pointer are kept on the thread stack and have no access from outside.
> 
> So the all point of this flag is the kernel driver telling mm that this
> address is enforced to only be accessed from one core-pinned thread.

What happens when the userspace part -- there is one, right, how else do
you get an mm to stick a vma in -- simply does a full address range
probe scan?

Something like this really needs a far more detailed Changelog that
explains how its to be used and how it is impossible to abuse. Esp. that
latter is _very_ important.
