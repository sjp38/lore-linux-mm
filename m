Reply-To: <frey@scs.ch>
From: "Martin Frey" <frey@scs.ch>
Subject: RE: how has set_pgdir been replaced in 2.4.x
Date: Mon, 10 Dec 2001 13:35:19 +0100
Message-ID: <00c801c1817e$bc3b4d70$03fe13ac@scs.ch>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20011210103855.A1919@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'Stephen C. Tweedie'" <sct@redhat.com>, 'Martin Maletinsky' <maletinsky@scs.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

>> I noticed that in the 2.4.x Linux kernel the function 
>set_pgdir() has gone (at least for most platforms). When 
>looking at code that modifies kernel page tables (e.g.
>> vmalloc_area_pages) I could not figure out, how the page 
>global directories are kept consistent. It looks to me as if
>> global page directory entries were modified in one global 
>page directory (the swapper_pg_dir) only. If this is the case, 
>I wonder how the modifications are 'propagated'
>> into all the other global page directories
>
>They are now faulted on demand for vmalloc.  The cost of manually
>updating all the pgds for every vmalloc is just too expensive if
>you've got tens of thousands of threads in the system.
>

Is there an implication on drivers, e.g. not accessing vmalloc'd
memory from within a page fault handler? A page fault from a
page fault handler is quite ugly...

Best regards, Martin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
