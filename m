Subject: Re: [PATCH *] VM patch for 2.4.0-test8
References: <Pine.LNX.4.21.0009140119560.1075-100000@duckman.distro.conectiva>
	<200009140525.WAA21446@pizda.ninka.net>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "David S. Miller"'s message of "Wed, 13 Sep 2000 22:25:14 -0700"
Date: 14 Sep 2000 08:11:40 +0200
Message-ID: <yttg0n3lcyr.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

>>>>> "david" == David S Miller <davem@redhat.com> writes:

david> In page_launder() about halfway down there is this sequence of tests
david> on LRU pages:

david> if (!clearedbuf) {
david>  ...
david> } else if (!page->mapping) {
david>  ...
david> } else if (page_count(page) > 1) {
david> } else /* page->mapping && page_count(page) == 1 */ {
david>  ...
david> }

david> Above this sequence we've done a page_cache_get.  For the final case
david> in the tests above (page->mapping != NULL && page_count(page) == 1)
david> have you checked if this ever happens or is even possible?

david> If the page is a page cache page (ie. page->mapping != NULL) it
david> should hold a reference.  Adding in our reference, the count should
david> always thus be > 1.

david> What did I miss?

I think nothing, I suppose that riel means > 2 and == 2, if we arrive
there when a page count of 1 we are in problems as you have told.

/me doing greping ...... <some time later>

I can only see one place where we add a page to the page cache and we
don't increase its page count, and it is in grow_buffers().  Could
somebody explain me _why_ we don't need to do a page_cache_get(page)
in that function? 

Later, Juan.



-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
