Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Thu, 11 May 2000 14:47:25 -0700 (PDT)"
Date: 11 May 2000 23:56:16 +0200
Message-ID: <yttya5ghhtr.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

linus> On 11 May 2000, Juan J. Quintela wrote:
>> - we change one page_cache_release to put_page in truncate_inode_pages
>> (people find lost when they see a get_page without the correspondent
>> put_page, and put_page and page_cache_release are synonimops)

linus> put_page() is _not_ synonymous with page_cache_release()!

linus> Imagine a time in the not too distant future when the page cache
linus> granularity is 8kB or 16kB due to better IO performance (possibly
linus> controlled by a config option), and page_cache_release() will do an
linus> "order=1" or "order=2" page free..

Linus, I agree with you here, but we do a get_page 5 lines before, I
think that if I do a get_page I should do a put_page to liberate it. 
But I can be wrong, and then I would like to know if in the future, it
could be posible to do a get_page and liberate it with a
page_cache_release?  That was my point.  Sorry for the bad wording.

Later, Juan.

PD. As always, I apreciate a lot your comments.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
