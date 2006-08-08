Date: Tue, 8 Aug 2006 19:19:47 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs
 invalidate race?
In-Reply-To: <44D7E584.10109@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0608081918320.30256@blonde.wat.veritas.com>
References: <44CF3CB7.7030009@yahoo.com.au> <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com>
 <44D74B98.3030305@yahoo.com.au> <Pine.LNX.4.64.0608071752040.20812@blonde.wat.veritas.com>
 <44D7E584.10109@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Nick Piggin wrote:
> 
> I wonder if we should have the i_size check (under the page lock) in
> do_no_page or down in the ->nopage implementations?

I'm inclined to say down in the ->nopage implementations.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
