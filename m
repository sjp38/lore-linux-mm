Date: Thu, 8 Feb 2007 13:42:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Drop PageReclaim()
In-Reply-To: <Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007, Christoph Lameter wrote:

> Could we put the page on the inactive list in shrink_page_list?

shrink_inactive_list() is the only caller of shrink_page_list(). So the 
page is already on the inactive list. The effect of the code is to move the
page back to the inactive list if it was touched while the page was 
written back. Why would we do this? A write ages the page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
