Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7856B026B
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:22:20 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r126so31300799wmr.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:22:20 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id p26si24359611wrp.311.2017.01.24.14.22.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 14:22:19 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id r144so38049135wme.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:22:19 -0800 (PST)
Date: Wed, 25 Jan 2017 01:22:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/12] uprobes: split THPs before trying replace them
Message-ID: <20170124222217.GB19920@node.shutemov.name>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
 <20170124162824.91275-2-kirill.shutemov@linux.intel.com>
 <20170124132849.73135e8c6e9572be00dbbe79@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124132849.73135e8c6e9572be00dbbe79@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jan 24, 2017 at 01:28:49PM -0800, Andrew Morton wrote:
> On Tue, 24 Jan 2017 19:28:13 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > For THPs page_check_address() always fails. It's better to split them
> > first before trying to replace.
> 
> So what does this mean.  uprobes simply fails to work when trying to
> place a probe into a THP memory region?

Looks like we can end up with endless retry loop in uprobe_write_opcode().

> How come nobody noticed (and reported) this when using the feature?

I guess it's not often used for anon memory.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
