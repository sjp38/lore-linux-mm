Date: Wed, 6 Nov 2002 21:15:38 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Usage of get_user_pages() in fs/aio.c
Message-ID: <20021106211538.M659@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ben,

in kernel 2.5.46 in file fs/aio.c line 150 you use
get_user_pages() in a way that makes no sense to me.

Your call is:

info->nr_pages = get_user_pages(current, ctx->mm,
                                  info->mmap_base, info->mmap_size, 
                                  1, 0, info->ring_pages, NULL);

info->mmap_size contains the number of BYTES mapped by the pages
in the ring_pages ARRAY.

get_user_pages() expects the number of ELEMENTS in the array
instead.

What this can cause is clear ;-)

Simple fix would be to replace "info->mmap_size" with "nr_pages",
that you compute just some lines above.

Please tell me, if I'm wrong here.

Regards

Ingo Oeser
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
