Date: Thu, 15 Mar 2007 23:59:29 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
Message-ID: <20070315225928.GF6687@v2.random>
References: <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <45F96CCB.4000709@redhat.com> <20070315162944.GI8321@wotan.suse.de> <Pine.LNX.4.64.0703151719380.32335@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703151719380.32335@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Chuck Ebbert <cebbert@redhat.com>, Ashif Harji <asharji@cs.uwaterloo.ca>, Miquel van Smoorenburg <miquels@cistron.nl>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 05:44:01PM +0000, Hugh Dickins wrote:
> who removed the !offset condition, he should be consulted on its
> reintroduction.

the !offset check looks a pretty broken heuristic indeed, it would
break random I/O. The real fix is to add a ra.prev_offset along with
ra.prev_page, and if who implements it wants to be stylish he can as
well use a ra.last_contiguous_read structure that has a page and
offset fields (and then of course remove ra.prev_page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
