Date: Thu, 3 Apr 2003 17:33:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
In-Reply-To: <8750000.1049385619@baldur.austin.ibm.com>
Message-ID: <Pine.LNX.4.44.0304031727420.2014-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Apr 2003, Dave McCracken wrote:
> 
> No, try_to_unmap will claim success when in fact there are still mappings.
> It'd be all right if it failed, but there's no way to tell it to fail.  The
> page will be freed by kswapd based on try_to_unmap's claim of success.

No: see the various checks on page_count(page) in vmscan.c:
though page_convert_anon temporarily leaves a page with neither
mapcount nor the right number of pte pointers, page_count is unaffected.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
