Date: Fri, 13 Jul 2001 00:15:25 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Updated VM statistics patch
Message-ID: <Pine.LNX.4.21.0107130003030.2821-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

I've updated the VM statistics patch. The following changed:

- Added CONFIG_VM_STATS option and Configure.help documentation
- Added Documentation/vm/statistics file which has a description
  of each stats field.
- Added more statistics:

vm_pgagescan: pages scanned by refill_inactive_scan()
vm_pgagedown: pages aged down by refill_inative_scan()
vm_pgageup: pages aged up by refill_inactive_scan()/try_to_swap_out()
vm_pgdeactfail_age: nr of deactivation failures on refill_inactive_scan()
due to >0 age
vm_pgdeactfail_ref: nr of deactivation failures on refill_inactive_scan()
due to zero aged pages with more users than the pagecache
vm_ptescan: nr of present ptes scanned by swap_out()
vm_pteunmap: nr of present ptes unmapped by swap_out()

- Changed the vmstat.c hack to not report separated per-zone information
by default, making the output more readable. If needed the per-zone
information can be seen with the "-z" option. 

Kernel patch (vmstatistics.patch) plus vmstat patch (vmstat.patch) plus
vmstat.c itself at 
http://bazar.conectiva.com.br/~marcelo/patches/v2.4/2.4.7pre5/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
