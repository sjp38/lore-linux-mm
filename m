Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 501ED6B026A
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:56:28 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so32251855wjb.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:56:28 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id 1si24450104wri.286.2017.01.24.14.56.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 14:56:27 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id r144so38242050wme.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:56:27 -0800 (PST)
Date: Wed, 25 Jan 2017 01:56:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/12] uprobes: split THPs before trying replace them
Message-ID: <20170124225625.GD19920@node.shutemov.name>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
 <20170124162824.91275-2-kirill.shutemov@linux.intel.com>
 <20170124132849.73135e8c6e9572be00dbbe79@linux-foundation.org>
 <20170124222217.GB19920@node.shutemov.name>
 <20170124143559.57cea7092a2efff940aeeef0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124143559.57cea7092a2efff940aeeef0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jan 24, 2017 at 02:35:59PM -0800, Andrew Morton wrote:
> On Wed, 25 Jan 2017 01:22:17 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Tue, Jan 24, 2017 at 01:28:49PM -0800, Andrew Morton wrote:
> > > On Tue, 24 Jan 2017 19:28:13 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > 
> > > > For THPs page_check_address() always fails. It's better to split them
> > > > first before trying to replace.
> > > 
> > > So what does this mean.  uprobes simply fails to work when trying to
> > > place a probe into a THP memory region?
> > 
> > Looks like we can end up with endless retry loop in uprobe_write_opcode().
> > 
> > > How come nobody noticed (and reported) this when using the feature?
> > 
> > I guess it's not often used for anon memory.
> 
> OK,  can we please include discussion of these things in the changelog?

Okay, I'll try to come up with a test case too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
