Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 04C9B6B0093
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 14:03:56 -0400 (EDT)
Date: Mon, 1 Oct 2012 20:03:49 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Virtual huge zero page
Message-ID: <20121001180349.GE18051@redhat.com>
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120929134811.GC26989@redhat.com>
 <5069B804.6040902@linux.intel.com>
 <20121001163118.GC18051@redhat.com>
 <5069CCF9.7040309@linux.intel.com>
 <20121001171519.GA20915@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121001171519.GA20915@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org

On Mon, Oct 01, 2012 at 08:15:19PM +0300, Kirill A. Shutemov wrote:
> I think performance is not the first thing we should look at. We need to
> choose which implementation is easier to support.

Having to introduce a special pmd bitflag requiring architectural
support is actually making it less self contained. The zero page
support is made optional of course, but the physical zero page would
have worked without the arch noticing.

> Applications which benefit from zero page are quite rare. We need to
> provide a huge zero page to avoid huge memory consumption with THP.
> That's it. Performance optimization for that rare case is overkill.

I still don't like the idea of some rare app potentially running
significantly slower (and we may not be notified because it's not a
breakage, if they're simulations it's hard to tell it's slower because
of different input or because of zero page being introduced). If we
knew for sure that zero pages accesses were always rare I wouldn't
care of course. But rare app != rare access.

The physical zero page patchset is certainly bigger, but it was mostly
localized in huge_memory.c so I don't see it at very intrusive even if
bigger.

Anyway if others sees the virtual zero page as easier to maintain, I'm
fine either ways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
