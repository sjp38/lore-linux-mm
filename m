Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4613F6B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 06:48:49 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id 200so21643939ykr.3
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 03:48:48 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id q69si19804701yhd.45.2014.02.04.03.48.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 03:48:48 -0800 (PST)
Message-ID: <52F0D39D.4050409@citrix.com>
Date: Tue, 4 Feb 2014 11:48:45 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Subject: [PATCH] xen: Properly account for _PAGE_NUMA
 during xen pte translations
References: <20140122032045.GA22182@falcon.amazon.com> <20140122050215.GC9931@konrad-lan.dumpdata.com> <20140122072914.GA9283@orcus.uplinklabs.net> <52DFD5DB.6060603@iogearbox.net> <CAEr7rXhJf1tf2KUErsGgUyYNUpVwLYD=fKUf8aPm0Dcg21MuNQ@mail.gmail.com> <20140122203337.GA31908@orcus.uplinklabs.net> <CAEr7rXjge6rKzxbwy+0A6-5YhVZL9WGmaLrDYbE8H5hrtwq_4A@mail.gmail.com> <20140124133830.GU4963@suse.de> <CAEr7rXjmVp-F88zQnc4a2tSzBAJFshzR0FPkOBdo1jbQLOv+2A@mail.gmail.com> <CAEr7rXgCoYW7O0E38YGCThUKgmxYFfLfYP-x_KSzVBLOCiHeDg@mail.gmail.com> <20140204114445.GM6732@suse.de>
In-Reply-To: <20140204114445.GM6732@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Steven Noonan <steven@uplinklabs.net>, Andrew Morton <akpm@linux-foundation.org>, George Dunlap <george.dunlap@eu.citrix.com>, Dario Faggioli <dario.faggioli@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Elena Ufimtseva <ufimtseva@gmail.com>, Linux Kernel mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, xen-devel <xen-devel@lists.xenproject.org>

On 04/02/14 11:44, Mel Gorman wrote:
> Steven Noonan forwarded a users report where they had a problem starting
> vsftpd on a Xen paravirtualized guest, with this in dmesg:
> 
[...]
> 
> The issue could not be reproduced under an HVM instance with the same kernel,
> so it appears to be exclusive to paravirtual Xen guests. He bisected the
> problem to commit 1667918b (mm: numa: clear numa hinting information on
> mprotect) that was also included in 3.12-stable.
> 
> The problem was related to how xen translates ptes because it was not
> accounting for the _PAGE_NUMA bit. This patch splits pte_present to add
> a pteval_present helper for use by xen so both bare metal and xen use
> the same code when checking if a PTE is present.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Thanks.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
