Date: Mon, 2 Apr 2007 22:42:02 +0200
From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: mbind and alignment
Message-ID: <20070402204202.GC3316@interface.famille.thibault.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

mbind(start, len, ...) currently requires that "start" be page-aligned,
but not "len" (which automatically gets page-rounded up).  This is a bit
odd:

- the userland type of start is void*, which people would expect to be a
  pointer to some variable.
- start needing to be page-aligned but len not needing to is not very
  consistent.
- none of this is documented in the manual page dated 2006-02-07

So one of those should probably be done to free people from headaches:

- document "start" requirement in the manual page
- require len to be aligned too, and document the requirements in the
  manual page
- drop the "start" requirement and just round down the page + adjust
  size automatically.

Samuel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
