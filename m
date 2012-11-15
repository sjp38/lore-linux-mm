Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B497B6B006C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 19:29:08 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so748029pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 16:29:08 -0800 (PST)
Date: Wed, 14 Nov 2012 16:29:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 00/11] Introduce huge zero page
In-Reply-To: <20121114133342.cc7bcd6e.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1211141626220.482@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <20121114133342.cc7bcd6e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 14 Nov 2012, Andrew Morton wrote:

> For this reason and for general ease-of-testing: can and should we add
> a knob which will enable users to disable the feature at runtime?  That
> way if it causes problems or if we suspect it's causing problems, we
> can easily verify the theory and offer users a temporary fix.
> 

I think it would be best to add a tunable under 
/sys/kernel/mm/transparent_hugepage and enable it by default whenever 
/sys/kernel/mm/transparent_hugepage/enabled is "always" or "madvise" and 
allocate the huge zero page under such circumstances.  Then we can free it 
if disabled (or if enabled is set to "never") and avoid all the 
refcounting and lazy allocation that causes a regression on Kirill's 
benchmark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
