Subject: More Oops with 2.3.99pre6
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 17 Apr 2000 12:04:46 +0200
Message-ID: <ytt1z45oxfl.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi
        I get the following Oops last night,  this box is one Athlon,
        Debian woody (unstable).  More information on request.  At
        that momment I was stressing the box (load 25 or similar).

        If you need more information, let me know.

Thanks a lot for your atention, Juan.
        

ksymoops 2.3.4 on i686 2.3.99-pre6.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.3.99-pre6/ (default)
     -m /boot/System.map-2.3.99-pre6 (default)

Unable to handle kernel NULL pointer dereference at virtual address 00000007
c013e1ee
*pde = 00000000
Oops: 0002
CPU:    0
EIP:    0010:[<c013e1ee>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010202
eax: c021ab00   ebx: c3bff500   ecx: 00000246   edx: 00000007
esi: ce006d80   edi: cf0eb9c0   ebp: 0000007d   esp: c14a1f9c
ds: 0018   es: 0018   ss: 0018
Process kswapd (pid: 2, stackpage=c14a1000)
Stack: 0000001d 00000006 00000004 c0217f00 c013e56a 00000094 c01296a3 00000006 
       00000004 c0217f00 c0217f00 c0217f00 c14a022d c14a0000 c0129765 00000004 
       c0217f00 00000f00 c14bdfb8 00000000 000000a0 c0108df8 00000000 00000078 
Call Trace: [<c013e56a>] [<c01296a3>] [<c0129765>] [<c0108df8>] 
Code: 89 02 89 1b 89 5b 04 8d 73 e0 83 7b e0 00 0f 85 a1 00 00 00 

>>EIP; c013e1ee <prune_dcache+1e/f0>   <=====
Trace; c013e56a <shrink_dcache_memory+1a/30>
Trace; c01296a3 <do_try_to_free_pages+43/90>
Trace; c0129765 <kswapd+75/f0>
Trace; c0108df8 <kernel_thread+28/40>
Code;  c013e1ee <prune_dcache+1e/f0>
00000000 <_EIP>:
Code;  c013e1ee <prune_dcache+1e/f0>   <=====
   0:   89 02                     mov    %eax,(%edx)   <=====
Code;  c013e1f0 <prune_dcache+20/f0>
   2:   89 1b                     mov    %ebx,(%ebx)
Code;  c013e1f2 <prune_dcache+22/f0>
   4:   89 5b 04                  mov    %ebx,0x4(%ebx)
Code;  c013e1f5 <prune_dcache+25/f0>
   7:   8d 73 e0                  lea    0xffffffe0(%ebx),%esi
Code;  c013e1f8 <prune_dcache+28/f0>
   a:   83 7b e0 00               cmpl   $0x0,0xffffffe0(%ebx)
Code;  c013e1fc <prune_dcache+2c/f0>
   e:   0f 85 a1 00 00 00         jne    b5 <_EIP+0xb5> c013e2a3 <prune_dcache+d3/f0>

Followed in the logs by:

Bad swap offset entry 0bd0a000
VM: killing process cc1
swap_free: offset exceeds max
swap_free: offset exceeds max
swap_free: Trying to free nonexistent swap-page
swap_free: offset exceeds max
swap_free: offset exceeds max
swap_free: Trying to free nonexistent swap-page


        

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
