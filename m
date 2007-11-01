Subject: per-bdi-throttling: synchronous writepage doesn't work correctly
Message-Id: <E1IndEw-00046x-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 01 Nov 2007 17:49:54 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: jdike@addtoit.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

It looks like bdi_thresh will always be zero if filesystem does
synchronous writepage, resulting in very poor write performance.

Hostfs (UML) is one such example, but there might be others.

The only solution I can think of is to add a set_page_writeback();
end_page_writeback() pair (or some reduced variant, that only does
the proportions magic).  But that means auditing quite a few
filesystems...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
