Subject: Ooops in filemap_write_page in test8
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 11 Sep 2000 17:00:11 +0200
Message-ID: <ytt8zszht38.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi
        I was running mmap001 over NFS when I got one Oops, with the
        following backtrace.  The problem is that the page->mapping is
        NULL, and it causes a NULL access at filemap_write_page.
        If you need any more info, let me know.

Later, Juan.



0xc29ff574 0xc012229f filemap_write_page+0xb (0xc760fec0, 0xc11a9540, 0x0)      
                               kernel .text 0xc0100000 0xc0122294 0xc01222ac    
           0xc01222be filemap_swapout+0x12 (0xc11a9540, 0xc760fec0)             
                               kernel .text 0xc0100000 0xc01222ac 0xc01222d0    
           0xc0126ca0 try_to_swap_out+0x150 (0xc1298120, 0xc2522c20, 0x4015d000,
 0xc29ff574, 0x4)                                                               
                               kernel .text 0xc0100000 0xc0126b50 0xc0126d70    
           0xc0126e83 swap_out_vma+0x113 (0xc1298120, 0xc2522c20, 0x4015d000, 0x
4)                                                                              
                               kernel .text 0xc0100000 0xc0126d70 0xc0126f08    
           0xc0126f4c swap_out_mm+0x44 (0xc1298120, 0x4)                        
                               kernel .text 0xc0100000 0xc0126f08 0xc0126f74    
           0xc012705f swap_out+0xeb (0x3c, 0x4)                                 
                               kernel .text 0xc0100000 0xc0126f74 0xc01270e4    
           0xc0127276 do_try_to_free_pages+0x192 (0x4, 0x10f00, 0xc1255fb8, 0x0)
                               kernel .text 0xc0100000 0xc01270e4 0xc012730c    
           0xc01273a9 kswapd+0x9d                                               
                               kernel .text 0xc0100000 0xc012730c 0xc01273b0    
           0xc0107488 kernel_thread+0x28                                        
                               kernel .text 0xc0100000 0xc0107460 0xc0107498    

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
