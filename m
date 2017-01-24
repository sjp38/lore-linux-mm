Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B25B26B0038
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:36:01 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e4so126490122pfg.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:36:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h82si20959988pfj.218.2017.01.24.14.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 14:36:00 -0800 (PST)
Date: Tue, 24 Jan 2017 14:35:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/12] uprobes: split THPs before trying replace them
Message-Id: <20170124143559.57cea7092a2efff940aeeef0@linux-foundation.org>
In-Reply-To: <20170124222217.GB19920@node.shutemov.name>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
	<20170124162824.91275-2-kirill.shutemov@linux.intel.com>
	<20170124132849.73135e8c6e9572be00dbbe79@linux-foundation.org>
	<20170124222217.GB19920@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 25 Jan 2017 01:22:17 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Tue, Jan 24, 2017 at 01:28:49PM -0800, Andrew Morton wrote:
> > On Tue, 24 Jan 2017 19:28:13 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > For THPs page_check_address() always fails. It's better to split them
> > > first before trying to replace.
> > 
> > So what does this mean.  uprobes simply fails to work when trying to
> > place a probe into a THP memory region?
> 
> Looks like we can end up with endless retry loop in uprobe_write_opcode().
> 
> > How come nobody noticed (and reported) this when using the feature?
> 
> I guess it's not often used for anon memory.

OK,  can we please include discussion of these things in the changelog?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
