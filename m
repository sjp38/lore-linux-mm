Subject: Re: Ooops in filemap_write_page in test8
References: <6D5D2176666@vcnet.vc.cvut.cz>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Petr Vandrovec"'s message of "Mon, 11 Sep 2000 17:06:01 MET-1"
Date: 11 Sep 2000 17:15:29 +0200
Message-ID: <ytt3dj7hsdq.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Petr Vandrovec <VANDROVE@vc.cvut.cz>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "petr" == Petr Vandrovec <VANDROVE@vc.cvut.cz> writes:

petr> On 11 Sep 00 at 17:00, Juan J. Quintela wrote:
>> I was running mmap001 over NFS when I got one Oops, with the
>> following backtrace.  The problem is that the page->mapping is
>> NULL, and it causes a NULL access at filemap_write_page.
>> If you need any more info, let me know.

petr> Hi Juan,
petr>   is your machine near to VMware or not? I reported same oopses
petr> last week on linux-kernel - they happened after heavy swapped VMware session
petr> on VMware exit (when exit_mmap was cleaning up address space). If you
petr> have idea where mapping gets set to NULL (and why is such page passed
petr> to filemap_write_page), I'd like to know it.
petr>                                           Thanks,
petr>                                             Petr Vandrovec
petr>                                             vandrove@vc.cvut.cz

I don't have vmware here, I am using NFSv3 (kernel NFS).  I am
investigating where the page puts ->mapping to NULL.  The Oops happend
because a page is in a vma with address operations, but the page
hasn't a mapping :((((

I continue working on that ....

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
