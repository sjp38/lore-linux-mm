From: David Howells <dhowells@redhat.com>
In-Reply-To: <Pine.LNX.4.64.0701291521540.24726@blonde.wat.veritas.com> 
References: <Pine.LNX.4.64.0701291521540.24726@blonde.wat.veritas.com>  <45BDCA8A.4050809@yahoo.com.au> 
Subject: Re: page_mkwrite caller is racy? 
Date: Thu, 01 Feb 2007 11:44:59 +0000
Message-ID: <5129.1170330299@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:

> > Must it be able to sleep?
> 
> Not as David was using it

It absolutely *must* be able to sleep.  It has to wait for FS-Cache to finish
writing the page to the cache before letting the PTE be made writable.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
