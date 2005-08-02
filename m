Message-ID: <ED373A183611D311A6220060943F134C084821FE@eag-eaga002e--n.americas.sgi.com>
From: Dan Higgins <djh@SGI.com>
Subject: RE: [patch 2.6.13-rc4] fix get_user_pages bug
Date: Tue, 2 Aug 2005 09:02:43 -0500 
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Linus Torvalds' <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@SGI.com>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Monday, August 01, 2005, Linus Torvalds wrote:
> 
> Also, I haven't actually heard from whoever actually
> noticed the problem in the first place (Robin?) whether
> the fix does fix it. It "obviously does", but testing
> is always good ;)

Robin took yesterday & today (Tues) off but will test the fix asap tomorrow.

---
Dan Higgins - SGI
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
