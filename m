Subject: Re: PATCH: Bug in invalidate_inode_pages()?
References: <Pine.LNX.4.10.10005081648230.5411-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Mon, 8 May 2000 16:51:44 -0700 (PDT)"
Date: 09 May 2000 01:55:52 +0200
Message-ID: <yttem7cvbp3.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:


Hi

linus> On 9 May 2000, Juan J. Quintela wrote:
>> I think that I have found a bug in invalidate_inode_pages.
>> It results that we don't remove the pages from the
>> &inode->i_mapping->pages list, then when we return te do the next loop
>> through all the pages, we can try to free a page that we have freed in
>> the previous pass.

linus> This is what "remove_inode_page()" does. Maybe that's not quite clear
linus> enough, so this function may certainly need some comments or something
linus> like that, but your patch is wrong (it will now delete the thing twice,
linus> which can and will result in list corruption).

Then there is the same inode->i_mapping_>pages list and page->list?
If that is the case I think that I would make one comment there
indicating that.

Later, Juan.




-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
