Received: (from mikes@localhost)
	by gnurds.org (8.9.3/) id VAA00924
	for linux-mm@kvack.org; Wed, 21 Feb 2001 21:02:02 -0600
Date: Wed, 21 Feb 2001 21:02:01 -0600
From: "Michael D . Stemle Jr" <mikes@gnurds.org>
Subject: My oops file....
Message-ID: <20010221210201.A905@gnurds.org>
Reply-To: mikes@gnurds.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AWniW0JNca5xppdA"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--AWniW0JNca5xppdA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Sorry.  I previously posted a bug report without the decoded oops.  Thanks
to marcelo in #kernelnewbies@irc.linux.com I figured out how to get an oops
decoded for you all.  Here's both the bug report I sent before, and the
decoded oops.

-- 
Michael D. Stemle, Jr.
------------------------
Gnurds Nurds for Unified
Remote Development of Software
--------------------------------
Gnurds Nurds Development Team
-------------------------------
http://www.gnurds.org
--AWniW0JNca5xppdA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="oops.txt"

ksymoops 2.3.4 on i686 2.4.0.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.0/ (default)
     -m /boot/System.map-2.4.0 (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

unable to handle kernel paging request at virtual address 39b45388
c013781a
*pde = 00000000
Oops: 0000
CPU: 0
EIP: 0010: [<c013781a>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010203
eax: 39b45360  ebx: 00000000  ecx: 00000000  edx: 00000000
esi: 39b45360  edi: c1df6180  ebp: 00000001  esp: c1133f78
ds: 0018  es: 0018  ss: 0018
Stack: c1075ad0 c1075aec 00000000 00000000 00000000 00000008 00000000 c012d878 c1075ad0
       00000000 00010f00 00000004 00000000 00000000 00000004 00000000 00000000
       0000003c 00000000 c012e0a0 00000004 00000000 00010f00 c0234577 c1132331
Call Trace: [<c012d878>] [<c012e0a0>] [<c012e168>] [<c01074c4>]
Code: 8b 76 28 8b 50 18 8b 40 10 83 e2 46 09 d0 0f 85 15 01 00 00

>>EIP; c013781a <try_to_free_buffers+6a/1e0>   <=====
Trace; c012d878 <page_launder+3a8/8b0>
Trace; c012e0a0 <do_try_to_free_pages+34/80>
Trace; c012e168 <kswapd+7c/11c>
Trace; c01074c4 <kernel_thread+28/38>
Code;  c013781a <try_to_free_buffers+6a/1e0>
00000000 <_EIP>:
Code;  c013781a <try_to_free_buffers+6a/1e0>   <=====
   0:   8b 76 28                  mov    0x28(%esi),%esi   <=====
Code;  c013781d <try_to_free_buffers+6d/1e0>
   3:   8b 50 18                  mov    0x18(%eax),%edx
Code;  c0137820 <try_to_free_buffers+70/1e0>
   6:   8b 40 10                  mov    0x10(%eax),%eax
Code;  c0137823 <try_to_free_buffers+73/1e0>
   9:   83 e2 46                  and    $0x46,%edx
Code;  c0137826 <try_to_free_buffers+76/1e0>
   c:   09 d0                     or     %edx,%eax
Code;  c0137828 <try_to_free_buffers+78/1e0>
   e:   0f 85 15 01 00 00         jne    129 <_EIP+0x129> c0137943 <try_to_free_buffers+193/1e0>


1 warning issued.  Results may not be reliable.

--AWniW0JNca5xppdA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="kernel.bug.txt"

I hadn't touched the machine for 2 days, other than SSH'ing in from work.
I came home this evening and hit the delete key.  I believe that this was
already on the screen, since nothing happened when I hit the key other than
the monitor came out of power-saver mode.
The machine would send the monitor into power-save mode, and everything appeared
to be running.  But when I was at work today, I couldn't access the machine through
CVS, HTTP, SSH, or SCP.  I could, however, ping it.
I was able to switch vitrual terminals, but I couldn't type any characters in.
I tried hitting CTRL-ALT-DEL, but that did nothing at all.  After I wrote the
error screen down (it took up an entire sheet of notebook paper), I hit the reset button.
Anyway, this is the message that was on the screen...
---------------------------------------------------------------------
unable to handle kernel paging request at virtual address 39b45388
printing eip:
c013781a
*pde = 00000000
Oops: 0000
CPU: 0
EIP: 0010: [<c013781a>]
EFLAGS: 00010203
eax: 39b45360  ebx: 00000000  ecx: 00000000  edx: 00000000
esi: 39b45360  edi: c1df6180  ebp: 00000001  esp: c1133f78
ds: 0018  es: 0018  ss: 0018
Process kswapd (pid: 4, stackpage = c1133000)
Stack: c1075ad0 c1075aec 00000000 00000000 00000000 00000008 00000000 c012d878 c1075ad0
       00000000 00010f00 00000004 00000000 00000000 00000004 00000000 00000000
       0000003c 00000000 c012e0a0 00000004 00000000 00010f00 c0234577 c1132331
Call Trace: [<c012d878>] [<c012e0a0>] [<c012e168>] [<c01074c4>]
Code: 8b 76 28 8b 50 18 8b 40 10 83 e2 46 09 d0 0f 85 15 01 00 00
---------------------------------------------------------------------

--AWniW0JNca5xppdA--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
