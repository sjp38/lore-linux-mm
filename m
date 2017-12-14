Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 229F76B025F
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 12:50:54 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w125so9859535itf.0
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 09:50:54 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id w87si1002352ioe.236.2017.12.14.09.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 09:50:53 -0800 (PST)
Date: Thu, 14 Dec 2017 18:50:32 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 00/17] x86/ldt: Use a VMA based read only mapping
Message-ID: <20171214175032.5aczgtwpwznngwzd@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <alpine.DEB.2.20.1712141302540.4998@nanos>
 <20171214120853.u2vc4x55faurkgec@hirez.programming.kicks-ass.net>
 <CALCETrV8MAVD_4mvQQ_=E2H1CMtRm=Axutqwc9hzjqkK8NwVSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrV8MAVD_4mvQQ_=E2H1CMtRm=Axutqwc9hzjqkK8NwVSQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 08:35:50AM -0800, Andy Lutomirski wrote:

> > @@ -3252,6 +3256,7 @@ static const struct vm_operations_struct
> >         .fault = special_mapping_fault,
> >         .mremap = special_mapping_mremap,
> >         .name = special_mapping_name,
> > +       .split = special_mapping_split,
> >  };
> >
> >  static const struct vm_operations_struct legacy_special_mapping_vmops = {
> 
> Disallowing splitting seems fine.  Disallowing munmap might not be.
> Certainly CRIU relies on being able to mremap() the VDSO.

And for mremap() we need do_munmap() to work, argh.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
