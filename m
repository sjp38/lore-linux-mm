Received: from megami.veritas.com (megami.veritas.com [192.203.46.101])
	by pallas.veritas.com (8.9.1a/8.9.1) with SMTP id OAA10598
	for <linux-mm@kvack.org>; Wed, 16 Aug 2000 14:03:06 -0700 (PDT)
Received: from saturn.homenet([192.168.225.243]) (4241 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <tigran@veritas.com>)
	id <m13PAFu-0000LkC@megami.veritas.com>
	for <linux-mm@kvack.org>; Wed, 16 Aug 2000 13:57:46 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #4 built 1999-Aug-24)
Date: Wed, 16 Aug 2000 22:04:51 +0100 (BST)
From: Tigran Aivazian <tigran@veritas.com>
Subject: 2.4.0-test7-pre4 oops in generic_make_request()
Message-ID: <Pine.LNX.4.21.0008162201590.1028-100000@saturn.homenet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi guys,

linux-kernel is dead so I am posting this oops here. This is
2.4.0-test7-pre4 slightly patched by

http://www.moses.uklinux.net/patches/linux-vxfs-2.4.0-test7-pre4.patch

(the patch is irrelevant to the oops but I list for completeness)

I was mkfs'ing a new filesystem on a 61G disk partition. Oops is
interesting (the fact that mkfs is actually mkfs.vxfs is totally
irrelevant - think of it as "some app" which writes some stuff to
/dev/hdd1).

Regards,
Tigran

ksymoops 0.7c on i686 2.4.0-test7.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.0-test7/ (default)
     -m /usr/src/linux/System.map (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Reading Oops report from the terminal
Unable to handle kernel NULL pointer dereference at virtual address 00000000
00000000
*pde = 00000000
Oops: 0000
CPU:    1
EIP:    0010:[<00000000>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: 00000000   ebx: daff6840   ecx: 00000000   edx: 00000000
esi: f55dbf20   edi: 00000000   ebp: 00000001   esp: db069aac
ds: 0018   es: 0018   ss: 0018
Process mkfs.vxfs (pid: 1406, stackpage=db069000)
Stack: c0182070 c0375980 00000000 daff6840 daff6840 f55dbf20 db069b10 00000001 
       f55dbf20 c0135c95 00000000 daff6840 00001641 db069d7c 00001000 0727fb80 
       c1e0ec00 00000200 00000000 00000001 00000000 00000000 00000e00 00000000 
Call Trace: [<c0182070>] [<c0135c95>] [<c0124f1d>] [<c0125089>] [<c0113763>] [<c0126493>] [<c010b330>] 
       [<c0126493>] [<c010b330>] [<c0120018>] [<c0275583>] [<c0147e8c>] [<c0125105>] [<c0123c1a>] [<c0123c39>] 
       [<c019e77f>] [<c0141424>] [<c019c120>] [<c019c154>] [<c0141424>] [<c019c120>] [<c019c154>] [<c0122007>] 
       [<c0122250>] [<c018c874>] [<c019aed9>] [<c018c874>] [<c018c3ae>] [<c019ad3c>] [<c019cd81>] [<c01325c5>] 
       [<c019e50c>] [<c0132716>] [<c010b207>] 
Warning (Oops_read): Code line not seen, dumping what data is available

>>EIP; 00000000 Before first symbol
Trace; c0182070 <generic_make_request+b4/118>
Trace; c0135c95 <brw_kiovec+1b9/334>
Trace; c0124f1d <do_no_page+55/b0>
Trace; c0125089 <handle_mm_fault+111/1b0>
Trace; c0113763 <do_page_fault+143/3f0>
Trace; c0126493 <merge_segments+1b/198>
Trace; c010b330 <error_code+2c/34>
Trace; c0126493 <merge_segments+1b/198>
Trace; c010b330 <error_code+2c/34>
Trace; c0120018 <do_proc_dointvec+70/30c>
Trace; c0275583 <clear_user+37/4c>
Trace; c0147e8c <padzero+1c/20>
Trace; c0125105 <handle_mm_fault+18d/1b0>
Trace; c0123c1a <map_user_kiobuf+192/24c>
Trace; c0123c39 <map_user_kiobuf+1b1/24c>
Trace; c019e77f <rw_raw_dev+247/2c8>
Trace; c0141424 <kill_fasync+24/30>
Trace; c019c120 <n_tty_receive_buf+dec/e54>
Trace; c019c154 <n_tty_receive_buf+e20/e54>
Trace; c0141424 <kill_fasync+24/30>
Trace; c019c120 <n_tty_receive_buf+dec/e54>
Trace; c019c154 <n_tty_receive_buf+e20/e54>
Trace; c0122007 <update_wall_time+b/3c>
Trace; c0122250 <timer_bh+38/2b4>
Trace; c018c874 <pty_write+110/11c>
Trace; c019aed9 <opost_block+191/1a0>
Trace; c018c874 <pty_write+110/11c>
Trace; c018c3ae <tty_default_put_char+1e/24>
Trace; c019ad3c <opost+1a0/1ac>
Trace; c019cd81 <write_chan+1cd/1e8>
Trace; c01325c5 <sys_llseek+b9/178>
Trace; c019e50c <raw_read+1c/24>
Trace; c0132716 <sys_read+92/a8>
Trace; c010b207 <system_call+33/38>


2 warnings issued.  Results may not be reliable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
