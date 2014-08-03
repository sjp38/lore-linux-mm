Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 70B2A6B0035
	for <linux-mm@kvack.org>; Sun,  3 Aug 2014 11:59:24 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id gl10so4541466lab.26
        for <linux-mm@kvack.org>; Sun, 03 Aug 2014 08:59:23 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id f1si23429623lam.9.2014.08.03.08.59.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 03 Aug 2014 08:59:22 -0700 (PDT)
Received: by mail-la0-f54.google.com with SMTP id hz20so4655456lab.27
        for <linux-mm@kvack.org>; Sun, 03 Aug 2014 08:59:21 -0700 (PDT)
MIME-Version: 1.0
From: Lucas Tanure <tanure@linux.com>
Date: Sun, 3 Aug 2014 12:59:06 -0300
Message-ID: <CAJyon0sfJ+_nBpR5u+jYxmnr+uTzard=_E+WeL-LVAkuQ3JnvQ@mail.gmail.com>
Subject: Questions about Kernel Memory that I didn't find answers in Google -
 Please Help
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kernelnewbies@kernelnewbies.org" <kernelnewbies@kernelnewbies.org>, linux-mm@kvack.org, kernel-mentors@selenic.com

Hi,

I'm looking for some site, pdf, book etc, that can answer this questions.
For now I have :
http://unix.stackexchange.com/questions/5124/what-does-the-virtual-kernel-memory-layout-in-dmesg-imply


I want to understand a few things about the memory and the execution
of Linux kernel.
Taking from a X86 and grub I have:

1) Grub loads kernel and root file system in memory, and the vmlinux
has the code to decompress it self, right ? linux

2) The address of load kernel is always the same ? And It's at
compilation time that is chosen ?

2a) The kernel takes places in 3g-4g memory place, and user space from 0 to 3gb.
But if the pc has only 256mb of memory ?
And when pc has 16gb of memory, the user space will be split in two ?

2b) And if kernel has soo many modules that needs more than 1gb to run ?

2c) How we configure all of that memory configs ? make menuconfig and friends ?

3) The function A will call functon B. B is at 0xGGGGGG in .text
section, but kernel was loaded in address 0xJJJJJJJJJJ, how A will
find B ?

4) Please consider this:
$ readelf -S -W vmlinux
There are 37 section headers, starting at offset 0xe05718:

Section Headers:
  [Nr] Name                           Type              Address
                Off             Size          ES Flg Lk Inf Al
  [ 0]                                      NULL
0000000000000000    000000      000000     00      0   0  0
  [ 1] .text                             PROGBITS
ffffffff81000000          200000     53129a      00  AX  0   0 4096
  [ 2] .notes                          NOTE
ffffffff8153129c          73129c     0001d8      00  AX  0   0  4
  [ 3] __ex_table                   PROGBITS        ffffffff81531480
       731480     002018      00   A  0   0  8
  [ 4] .rodata                         PROGBITS
ffffffff81600000          800000     1655ee     00   A  0   0 64
  [ 5] __bug_table                 PROGBITS        ffffffff817655f0
       9655f0      005424     00   A  0   0  1
  [ 6] .pci_fixup                     PROGBITS        ffffffff8176aa18
         96aa18     002f88      00   A  0   0  8
  [ 7] .tracedata                    PROGBITS        ffffffff8176d9a0
        96d9a0     00003c     00   A  0   0  1
  [ 8] __ksymtab                   PROGBITS        ffffffff8176d9e0
      96d9e0     00e710     00   A  0   0 16
  [ 9] __ksymtab_gpl             PROGBITS        ffffffff8177c0f0
    97c0f0      00a150      00   A  0   0 16
  [10] __kcrctab                     PROGBITS        ffffffff81786240
       986240     007388     00   A  0   0  8
  [11] __kcrctab_gpl              PROGBITS        ffffffff8178d5c8
     98d5c8     0050a8     00   A  0   0  8
  [12] __ksymtab_strings      PROGBITS        ffffffff81792670
 992670     01cb42   00   A  0   0  1
  [13] __init_rodata               PROGBITS        ffffffff817af1c0
       9af1c0      0000e8   00   A  0   0 32
  [14] __param                      PROGBITS        ffffffff817af2a8
        9af2a8     000b00   00   A  0   0  8
  [15] __modver                    PROGBITS        ffffffff817afda8
       9afda8     000258   00   A  0   0  8
  [16] .data                            PROGBITS
ffffffff81800000          a00000     0e1180   00  WA  0   0 4096
  [17] .vvar                            PROGBITS
ffffffff818e2000          ae2000     001000   00  WA  0   0 16
  [18] .data..percpu               PROGBITS        0000000000000000
c00000     015300   00  WA  0   0 4096
  [19] .init.text                       PROGBITS
ffffffff818f9000           cf9000      0503ea   00  AX  0   0 16
  [20] .init.data                      PROGBITS
ffffffff8194a000           d4a000    09e4c8   00  WA  0   0 4096
  [21] .x86_cpu_dev.init        PROGBITS        ffffffff819e84c8
    de84c8    000018   00   A  0   0  8
  [22] .parainstructions         PROGBITS        ffffffff819e84e0
     de84e0    00bd3c   00   A  0   0  8
  [23] .altinstructions            PROGBITS        ffffffff819f4220
        df4220     005f40   00   A  0   0  1
  [24] .altinstr_replacement  PROGBITS        ffffffff819fa160
  dfa160     001a69   00  AX  0   0  1
  [25] .iommu_table              PROGBITS        ffffffff819fbbd0
     dfbbd0     0000f0   00   A  0   0  8
  [26] .apicdrivers                 PROGBITS        ffffffff819fbcc0
         dfbcc0     000020   00  WA  0   0  8
  [27] .exit.text                     PROGBITS        ffffffff819fbce0
           dfbce0     0009bc   00  AX  0   0  1
  [28] .smp_locks                  PROGBITS        ffffffff819fd000
        dfd000    005000   00   A  0   0  4
  [29] .data_nosave              PROGBITS        ffffffff81a02000
     e02000    001000   00  WA  0   0  4
  [30] .bss                             NOBITS
ffffffff81a03000            e03000    122000   00  WA  0   0 4096
  [31] .brk                              NOBITS
ffffffff81b25000           e03000    425000   00  WA  0   0  1
  [32] .comment                   PROGBITS        0000000000000000
e03000    000027   01  MS  0   0  1
  [33] .debug_frame             PROGBITS        0000000000000000
e03028    002560   00      0   0  8
  [34] .shstrtab                     STRTAB
0000000000000000     e05588    00018a 00      0   0  1
  [35] .symtab                      SYMTAB            0000000000000000
    e06058    1a29f8 18     36 43659  8
  [36] .strtab                         STRTAB
0000000000000000     fa8a50    180d92 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), l (large)
  I (info), L (link order), G (group), T (TLS), E (exclude), x (unknown)
  O (extra OS processing required) o (OS specific), p (processor specific)

So the vmlinux is loaded in memory like a dd ?

5) In my function A, inside the module that I wrote, a non-initialized
variable will take place in non-initialized section that was loaded in
memory ?
Or my modules has a new sections for it's own use, and my module is
loaded my memory like a process, with all his sections?
So how another module or kernel code will fin my exported variable/function ?


6) Let's suppose:
I have a int variable, with 17 as content, and the address is 0xGGGGGG.
If I stop the linux in this time, read my memory at address 0xGGGGGG I
will got 17, right ?
0xGGGGGGG will be bigger than 0xc0000000 always,  right ?


7) Now take int from question and change for:
struct mystruct * foo = (struct mystruct* ) kmalloc(sizeof(struct mystruct));

I will be able to read at address 0xGGGGGG the struct that created,
and it address will be greater than 0xc0000000, right ?
But for this struct, the memory will be allocated for ever, until I
free the pointer, right ?



Well, this just a start. I really want to understand how kernel is
run, loaded etc. Any help is appreciate, answering my questions, links
to read, books to read.
Actually, I didn't find any book with that kind of information .


--
Lucas Tanure
+55 (19) 988176559

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
