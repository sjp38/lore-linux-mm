Subject: 2.5.33-mm4 filemap_copy_from_user: Unexpected page fault
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 06 Sep 2002 09:48:05 -0600
Message-Id: <1031327285.1984.155.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

With 2.5.33-mm4, I tried running dbench on an ext2 partition and was
able to run up to dbench 80 successfully.  However, at dbench 96, I got
four messages like this:

filemap_copy_from_user: Unexpected page fault

Shortly after this, the box hung again, responsive to pings but little
else.  I did sysrq-p and typed in the results, which are slightly
different than before using an ext3 partition. Sysrq-e and sysrq-i had
no effect, so I had to sysrq-b. The following fsck on the ext2 disk was
not fun. It may be worth noting that this hang occurred at 96 clients
with dbench on ext2 and at 8 clients on ext3 (data=ordered).

Here is the output of ksymoops on the sysrq-p result:

Steven

[steven@spc5 linux-2.5.33-mm4]$ ksymoops -K -L -O -v vmlinux -m System.map <mm4-sysrq-p.txt
ksymoops 2.4.4 on i686 2.5.33.  Options used
     -v vmlinux (specified)
     -K (specified)
     -L (specified)
     -O (specified)
     -m System.map (specified)

Pid: 1945, comm:        pdflush
EIP: 068:[<c0159bf4>] CPU: 1 EFLAGS: 00000202   Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EAX: 00000001 EBX: c90f3730 ECX: c90f3738 EDX: eb32bf88
ESI: c90f3730 EDI: 000065c2 EBP: 00000001 DS: 0068 ES: 0068
CR0: 8005003b CR2: 4212db0c CR3: 2a378000 CR4: 00000690
Call Trace: [<c0159e1e>] [<c013b8aa>] [<c013b4cb>] [<c013b570>] [<c013b57b>]
   [<c013b830>] [<c0107284>] [<c0107289>]
Warning (Oops_read): Code line not seen, dumping what data is available

>>EIP; c0159bf4 <sync_sb_inodes+84/260>   <=====
Trace; c0159e1e <writeback_inodes+4e/80>
Trace; c013b8aa <background_writeout+7a/c0>
Trace; c013b4cb <__pdflush+12b/1d0>
Trace; c013b570 <pdflush+0/10>
Trace; c013b57b <pdflush+b/10>
Trace; c013b830 <background_writeout+0/c0>
Trace; c0107284 <kernel_thread_helper+0/c>
Trace; c0107289 <kernel_thread_helper+5/c>


1 warning issued.  Results may not be reliable.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
