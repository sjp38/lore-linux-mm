From: "Petr Vandrovec" <VANDROVE@vc.cvut.cz>
Date: Mon, 11 Sep 2000 17:06:01 MET-1
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Subject: Re: Ooops in filemap_write_page in test8
Message-ID: <6D5D2176666@vcnet.vc.cvut.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11 Sep 00 at 17:00, Juan J. Quintela wrote:
>         I was running mmap001 over NFS when I got one Oops, with the
>         following backtrace.  The problem is that the page->mapping is
>         NULL, and it causes a NULL access at filemap_write_page.
>         If you need any more info, let me know.

Hi Juan,
  is your machine near to VMware or not? I reported same oopses
last week on linux-kernel - they happened after heavy swapped VMware session
on VMware exit (when exit_mmap was cleaning up address space). If you
have idea where mapping gets set to NULL (and why is such page passed
to filemap_write_page), I'd like to know it.
                                          Thanks,
                                            Petr Vandrovec
                                            vandrove@vc.cvut.cz
                                            
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
