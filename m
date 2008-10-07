Message-ID: <48EB8314.1030701@linux-foundation.org>
Date: Tue, 07 Oct 2008 10:41:08 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH next 1/3] slub defrag: unpin writeback pages
References: <Pine.LNX.4.64.0810050319001.22004@blonde.site> <48EB62F9.9040409@linux-foundation.org> <Pine.LNX.4.64.0810071606530.32764@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0810071606530.32764@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

> But since the cacheline is already dirty (from get_page_unless_zero),
> and it's only a trylock, and we (almost certainly) need to repeat the
> PageWriteback test once we've got the lock, and it does not hit this
> case often enough for you to have noticed the missing put_page() bug,
> I decided to save icache instead by just removing your optimization.

Ok. Acked-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
