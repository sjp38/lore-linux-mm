From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008101718.KAA33467@google.engr.sgi.com>
Subject: pte_pagenr/MAP_NR deleted in pre6
Date: Thu, 10 Aug 2000 10:18:49 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: rmk@arm.linux.org.uk, nico@cam.org, davem@redhat.com, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Thought I would send out a quick note about a change I put into test6.
Basically, to make it easier to implement DISCONTIGMEM systems, the
concepts of page/mem_map number/index has been killed from the generic
(non architecture specific) parts of the kernel. This includes MAP_NR,
pte_pagenr and max_mapnr (although max_mapnr is used by a lot of 
architectures, it is not used by the generic kernel anymore).

New macros that have been born to replace the above ones are 
virt_to_page (thusly named by Linus!), which will take a kernel direct
mapped address as input and provide the corresponding struct page. The
other one is VALID_PAGE(), which given a page struct, determines whether
it is a valid page struct and represents _physical_ memory.   

Both of virt_to_page and VALID_PAGE are in include/asm*/page.h. I have 
tried to make sure there were no mistakes when making the changes for
the various architectures, but I am sure I goofed up a few cases, so 
apologies in advance. 

Also, as I have suggested before, the pte_page implementation in
sparc/sparc64 should be cleaned up, and the usages of MAP_NR in the
arm code. Russell, Linus has not put in the final patch that will 
allow DISCONTIGMEM systems to lay out their mem_map arrays however
they see fit, I have resent it to him, if that is put in, we can get
down to simplifying most of the DISCONTIG arch code.

Thanks.

Kanoj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
