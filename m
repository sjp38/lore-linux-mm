Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1186B0253
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 03:11:53 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k100so9633425wrc.9
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 00:11:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v11sor8376971edb.25.2017.11.22.00.11.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 00:11:50 -0800 (PST)
Date: Wed, 22 Nov 2017 11:11:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 2/2] x86/selftests: Add test for mapping placement for
 5-level paging
Message-ID: <20171122081147.5gjushlstmnnmlev@node.shutemov.name>
References: <20171115143607.81541-1-kirill.shutemov@linux.intel.com>
 <20171115143607.81541-2-kirill.shutemov@linux.intel.com>
 <87y3myzx7z.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y3myzx7z.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 22, 2017 at 11:11:36AM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > With 5-level paging, we have 56-bit virtual address space available for
> > userspace. But we don't want to expose userspace to addresses above
> > 47-bits, unless it asked specifically for it.
> >
> > We use mmap(2) hint address as a way for kernel to know if it's okay to
> > allocate virtual memory above 47-bit.
> >
> > Let's add a self-test that covers few corner cases of the interface.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Can we move this to selftest/vm/ ? I had a variant which i was using to
> test issues on ppc64. One change we did recently was to use >=128TB as
> the hint addr value to select larger address space. I also would like to
> check for exact mmap return addr in some case. Attaching below the test
> i was using. I will check whether this patch can be updated to test what
> is converted in my selftest. I also want to do the boundary check twice.
> The hash trasnslation mode in POWER require us to track addr limit and
> we had bugs around address space slection before and after updating the
> addr limit.

Feel free to move it to selftest/vm. I don't have time to test setup and
test it on Power myself, but this would be great.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
