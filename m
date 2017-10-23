Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA1606B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 07:57:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r202so6623096wmd.17
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 04:57:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b74sor1204385wme.62.2017.10.23.04.57.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Oct 2017 04:57:06 -0700 (PDT)
Date: Mon, 23 Oct 2017 13:56:58 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171023115658.geccs22o2t733np3@gmail.com>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
 <20171003082754.no6ym45oirah53zp@node.shutemov.name>
 <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
 <20171020081853.lmnvaiydxhy5c63t@gmail.com>
 <20171020094152.skx5sh5ramq2a3vu@black.fi.intel.com>
 <20171020152346.f6tjybt7i5kzbhld@gmail.com>
 <20171020162349.3kwhdgv7qo45w4lh@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171020162349.3kwhdgv7qo45w4lh@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> > Or, could we keep MAX_PHYSMEM_BITS constant, and introduce a _different_ constant 
> > that is dynamic, and which could be used in the cases where the 5-level paging 
> > config causes too much memory footprint in the common 4-level paging case?
> 
> This is more labor intensive case with unclear benefit.
> 
> Dynamic MAX_PHYSMEM_BITS doesn't cause any issue in waste majority of
> cases.

Almost nothing uses it - and even in those few cases it caused problems.

Making a variable that 'looks' like a constant macro dynamic in a rare Kconfig 
scenario is asking for trouble.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
