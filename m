Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 13E956B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 23:18:25 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id n128so110569532pfn.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 20:18:25 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id xj5si6549547pab.84.2016.01.26.20.18.24
        for <linux-mm@kvack.org>;
        Tue, 26 Jan 2016 20:18:24 -0800 (PST)
Date: Tue, 26 Jan 2016 23:18:21 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 2/3] mm: Convert vm_insert_pfn_prot to vmf_insert_pfn_prot
Message-ID: <20160127041821.GQ2948@linux.intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453742717-10326-3-git-send-email-matthew.r.wilcox@intel.com>
 <CALCETrWQdJFBMz+O3TtVfMwAapY1tJFg3PE+-Gjp7fOWkzrAAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWQdJFBMz+O3TtVfMwAapY1tJFg3PE+-Gjp7fOWkzrAAA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 25, 2016 at 09:35:36AM -0800, Andy Lutomirski wrote:
> On Mon, Jan 25, 2016 at 9:25 AM, Matthew Wilcox
> <matthew.r.wilcox@intel.com> wrote:
> > From: Matthew Wilcox <willy@linux.intel.com>
> >
> > Other than the name, the vmf_ version takes a pfn_t parameter, and
> > returns a VM_FAULT_ code suitable for returning from a fault handler.
> >
> > This patch also prevents vm_insert_pfn() from returning -EBUSY.
> > This is a good thing as several callers handled it incorrectly (and
> > none intentionally treat -EBUSY as a different case from 0).
> >
> > Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> 
> This would be even nicer if you added vmf_insert_pfn as well :)

I've sent out patches adding it before ... my most recent attempt on
January 5th tied up with the DAX support for 1GB pages.  I'll keep
sending it until it sticks :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
