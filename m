Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Fwd: kernel BUG at page_alloc.c:75! / exit.c
Date: Wed, 4 Apr 2001 21:36:09 +0200
MIME-Version: 1.0
Message-Id: <01040421360901.00634@jeloin>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ernte23@gmx.de
List-ID: <linux-mm.kvack.org>

Hi,

Forwarding to linux-mm since Riel does not read linux-kernel any more...

/RogerL

----------  Forwarded Message  ----------
Subject: kernel BUG at page_alloc.c:75! / exit.c
Date: Wed, 04 Apr 2001 13:23:51 +0200
From: ernte23@gmx.de
To: linux-kernel@vger.kernel.org


hi,

I'm running the 2.4.3 kernel and my system always (!) crashes when I try
to generate the "Linux kernel poster" from lgp.linuxcare.com.au. After
working for one hour, the kernel printed this message:

kernel BUG at page_alloc.c:75!
invalid operand: 0000
CPU:    0
EIP:    0010:[__free_pages_ok+62/784]
EFLAGS: 00010296
eax: 0000001f   ebx: c137dbb8   ecx: 00000000   edx: ffffffff
esi: c137dbb8   edi: c0223fb8   ebp: 00000000   esp: c1475f78
ds: 0018   es: 0018   ss: 0018
Process bdflush (pid: 5, stackpage=c1475000)
Stack: c01f6ec5 c01f6fd3 0000004b c137dbe0 c137dbb8 c0223fb8 0000003c
c0223fb8
       0000003b c48a1a40 00000003 c0128a89 c012a29a c0128c85 c1474000
c01f852e
       0000000a 0008e000 00000000 00000000 00000004 00000000 00007a13
c0132ae0
Call Trace: [page_launder+793/2064] [__free_pages+26/32]
[page_launder+1301/2064] [bdflush+128/208] [kernel_thread+35/48]

Code: 0f 0b 83 c4 0c 89 d8 2b 05 78 ea 27 c0 69 c0 f1 f0 f0 f0 c1
kernel BUG at exit.c:458!
invalid operand: 0000
CPU:    0
EIP:    0010:[do_exit+526/544]
EFLAGS: 00010282
eax: 0000001a   ebx: c0220920   ecx: 00000000   edx: ffffffff

I think there should be more, but it stopped at this point.

Do you need more information about the system?

Thank you, Felix
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

-------------------------------------------------------

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
