Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17Zaij-0000VM-00
	for <linux-mm@kvack.org>; Tue, 30 Jul 2002 10:23:41 -0700
Date: Tue, 30 Jul 2002 10:23:41 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: severely bloated slabs
Message-ID: <20020730172341.GD29537@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

12 hours after running dbench, tiobench, and a couple of others:

             cache      active    alloc    %util
       buffer_head:     3781KB   132278KB    2.85
         pte_chain:       46KB      520KB    8.98
      dentry_cache:     8256KB    47662KB   17.32
    vm_area_struct:      226KB      817KB   27.75
               bio:       98KB      295KB   33.26
          biovec-1:       25KB       75KB   33.45
           size-32:      377KB     1098KB   34.38
           size-64:      251KB      700KB   35.93
  proc_inode_cache:      517KB     1157KB   44.74
       task_struct:      788KB     1697KB   46.47
         size-4096:     2480KB     5240KB   47.32
        signal_act:      688KB     1379KB   49.86
 skbuff_head_cache:      384KB      738KB   52.3 
          tcp_sock:      465KB      767KB   60.63
   radix_tree_node:     9533KB    14851KB   64.18
       files_cache:      487KB      677KB   71.96
  sock_inode_cache:      248KB      341KB   72.74
          sgpool-8:      195KB      255KB   76.83
         size-2048:     1132KB     1372KB   82.50
          size-256:      606KB      701KB   86.52
  tcp_open_request:       54KB       62KB   87.43


132MB of ZONE_NORMAL on a 16GB i386 box tied up in buffer_head slabs
when all of 3% of it is in use gives me the willies. Periodic slab
pruning anyone? Might be useful in addition to slab-in-lru.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
