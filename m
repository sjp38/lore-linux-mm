Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 692066B000A
	for <linux-mm@kvack.org>; Tue, 15 May 2018 03:09:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g1-v6so12487031pfh.19
        for <linux-mm@kvack.org>; Tue, 15 May 2018 00:09:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b79-v6si12252788pfm.104.2018.05.15.00.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 00:09:01 -0700 (PDT)
Date: Tue, 15 May 2018 00:08:57 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180515070856.GA8522@infradead.org>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <1d5f676f-b5d1-3ad3-c7a5-25b390c0e44e@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d5f676f-b5d1-3ad3-c7a5-25b390c0e44e@netapp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Mon, May 14, 2018 at 09:26:13PM +0300, Boaz Harrosh wrote:
> I am please pushing for this patch ahead of the push of ZUFS, because
> this is the only patch we need from otherwise an STD Kernel.
> 
> We are partnering with Distro(s) to push ZUFS out-of-tree to beta clients
> to try and stabilize such a big project before final submission and
> an ABI / on-disk freeze.
> 

Please stop this crap.  If you want any new kernel functionality send
it together with a user.  Even more so for something as questionanble
and hairy as this.

With a stance like this you disqualify yourself.
