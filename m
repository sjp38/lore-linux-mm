From: Andi Kleen <ak@suse.de>
Subject: Re: [discuss] [PATCH] Inconsistent mmap()/mremap() flags
Date: Tue, 2 Oct 2007 15:45:32 +0200
References: <1190958393.5128.85.camel@phantasm.home.enterpriseandprosperity.com> <1191308772.5200.66.camel@phantasm.home.enterpriseandprosperity.com> <Pine.LNX.4.64.0710021304230.26719@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0710021304230.26719@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710021545.32556.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: discuss@x86-64.org
Cc: Hugh Dickins <hugh@veritas.com>, Thayne Harbaugh <thayne@c2.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> First call mmap with a low hint address, the new size you'll be wanting
> from the mremap, PROT_NONE, MAP_ANONYMOUS, -1, 0.  Then call mremap with
> old address, old size, new size, MREMAP_MAYMOVE|MREMAP_FIXED, and new
> address as returned by the preparatory mmap.

That's racy unfortunately in a multithreaded process. They would need to loop.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
