Date: Fri, 27 Sep 2002 22:28:13 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: mremap() pte allocation atomicity error
Message-ID: <20020928052813.GY22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I'm working on something else atm.

 [<c01187b3>]__might_sleep+0x43/0x47
 [<c013b6d4>]__alloc_pages+0x24/0x20c
 [<c0133650>]file_read_actor+0x0/0x1b0
 [<c01131ed>]pte_alloc_one+0x41/0x104 
 [<c012d05d>]pte_alloc_map+0x4d/0x210
 [<c013bc73>]get_page_cache_size+0xf/0x18
 [<c0135f38>]move_one_page+0xe8/0x328    
 [<c0136061>]move_one_page+0x211/0x328
 [<c0130644>]vm_enough_memory+0x34/0xc0
 [<c01361a9>]move_page_tables+0x31/0x7c
 [<c0136860>]do_mremap+0x66c/0x7ec     
 [<c0136a30>]sys_mremap+0x50/0x73 
 [<c010748f>]syscall_call+0x7/0xb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
