Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.10.10005090844050.1100-100000@penguin.transmeta.com>
From: Christoph Rohland <cr@sap.com>
Date: 09 May 2000 19:42:59 +0200
In-Reply-To: Linus Torvalds's message of "Tue, 9 May 2000 08:44:43 -0700 (PDT)"
Message-ID: <qww1z3bmxgc.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Stone <tamriel@ductape.net>, riel@nl.linux.org, Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> Try out the really recent one - pre7-8. So far it hassome good reviews,
> and I've tested it both on a 20MB machine and a 512MB one..

Nope, does more or less lockup after the first attempt to swap
something out. I can still run ls and free. but as soon as something
touches /proc it locks up. Also my test programs do not do anything
any more.

I append the mem and task info from sysrq. Mem info seems to not
change after lockup.

Greetings
		Christoph

SysRq: Show Memory
Mem-info:
Free pages:      713756kB (  2040kB HighMem)
( Free: 178439, lru_cache: 3149 (1024 2048 3072) )
  DMA: 1*4kB 2*8kB 1*16kB 4*32kB 3*64kB 3*128kB 1*256kB 1*512kB 0*1024kB 6*2048kB = 13796kB)
  Normal: 0*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 340*2048kB = 697920kB)
  HighMem: 2*4kB 0*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB = 2040kB)
Swap cache: add 0, delete 0, find 0/0
Free swap:       4048296kB
2162688 pages of RAM
1867776 pages of HIGHMEM
104332 reserved pages
868894 pages shared
0 pages swap cached
0 pages in page table cache
Buffer memory:     1340kB
    CLEAN: 175 buffers, 700 kbyte, 3 used (last=47), 0 locked, 0 protected, 0 dirty
   LOCKED: 217 buffers, 868 kbyte, 19 used (last=190), 0 locked, 0 protected, 0
dirty                                                                           

SysRq: Show State

                         free                        sibling
  task             PC    stack   pid father child younger older
init      R C1089F0C     0     1      0   612  (NOTLB)
   sig: 0 0000000000000000 0000000000000000 : X
kswapd    D C4F154E8     0     2      1        (L-TLB)       3
   sig: 0 0000000000000000 ffffffffffffffff : X
kflushd   S C3FEC000     0     3      1        (L-TLB)       4     2
   sig: 0 0000000000000000 ffffffffffffffff : X
kupdate   R C3FEBFC4     0     4      1        (L-TLB)     278     3
   sig: 0 0000000000000000 fffffffffff9ffff : X
portmap   S 7FFFFFFF  2856   278      1        (NOTLB)     341     4
   sig: 0 0000000000000000 0000000000000000 : X
syslogd   R 7FFFFFFF     0   341      1        (NOTLB)     352   278
   sig: 1 0000000000002000 0000000000000000 : 14 X
klogd     R C3E78000     0   352      1        (NOTLB)     368   341
   sig: 0 0000000000000000 0000000000000000 : X
atd       S C3E49F78  2856   368      1        (NOTLB)     384   352
   sig: 0 0000000000000000 0000000000010000 : X
crond     R C3E3DF78  2856   384      1        (NOTLB)     404   368
   sig: 0 0000000000000000 0000000000000000 : X
inetd     S 7FFFFFFF  2856   404      1        (NOTLB)     413   384
   sig: 0 0000000000000000 0000000000000000 : X
sshd      S 7FFFFFFF     0   413      1   634  (NOTLB)     429   404
   sig: 0 0000000000000000 0000000000000000 : X
lpd       S 7FFFFFFF     0   429      1        (NOTLB)     469   413
   sig: 0 0000000000000000 0000000000000000 : X
automount  R C3EC56C0     0   469      1        (NOTLB)     471   429
   sig: 1 0000000000002000 0000000000000000 : 14 X
automount  R CD486AA0  4992   471      1        (NOTLB)     511   469
   sig: 1 0000000000002000 0000000000000000 : 14 X
sendmail  R C119FF0C  5956   511      1        (NOTLB)     528   471
   sig: 0 0000000000000000 0000000000000000 : X
gpm       S C117BF0C     0   528      1        (NOTLB)     544   511
   sig: 0 0000000000000000 0000000000000000 : X
httpd     R C1181F0C     0   544      1   557  (NOTLB)     571   528
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S C117DF38     0   548    544        (NOTLB)     549
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S C1185F38     0   549    544        (NOTLB)     550   548
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S 7FFFFFFF     0   550    544        (NOTLB)     551   549
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S C113FF38     0   551    544        (NOTLB)     552   550
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S C1133F38     0   552    544        (NOTLB)     553   551
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S C1129F38     0   553    544        (NOTLB)     554   552
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S C1127F38     0   554    544        (NOTLB)     555   553
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S C110FF38     0   555    544        (NOTLB)     556   554
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S C1101F38     0   556    544        (NOTLB)     557   555
   sig: 0 0000000000000000 0000000000000000 : X
httpd     S F75F5F38     0   557    544        (NOTLB)           556
   sig: 0 0000000000000000 0000000000000000 : X
xfs       S F75B7F0C     0   571      1        (NOTLB)     606   544
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  S 7FFFFFFF  5124   606      1        (NOTLB)     607   571
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  S 7FFFFFFF  2856   607      1        (NOTLB)     608   606
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  S 7FFFFFFF  2856   608      1        (NOTLB)     609   607
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  S 7FFFFFFF  2856   609      1        (NOTLB)     610   608
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  S 7FFFFFFF  2856   610      1        (NOTLB)     611   609
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  S 7FFFFFFF  2856   611      1        (NOTLB)     612   610
   sig: 0 0000000000000000 0000000000000000 : X
login     S 00000000  2856   612      1   617  (NOTLB)           611
   sig: 0 0000000000000000 0000000000000000 : X
bash      S 00000000     0   617    612   633  (NOTLB)
   sig: 0 0000000000000000 0000000000010000 : X
vmstat    R F74E5F78     0   633    617        (NOTLB)
   sig: 1 0000000000080000 0000000000000000 : 20 X
sshd      R 7FFFFFFF     0   634    413   636  (NOTLB)
   sig: 0 0000000000000000 0000000000000000 : X
xterm     S 7FFFFFFF  4900   636    634   639  (NOTLB)
   sig: 0 0000000000000000 0000000000000000 : X
bash      S 7FFFFFFF     0   639    636   652  (NOTLB)
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R F746A000  2856   642    639   651  (NOTLB)     652
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    D F6AB52B4  2856   643    642        (NOTLB)     644
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R F7458000     0   644    642        (NOTLB)     645   643
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R F7448000     0   645    642        (NOTLB)     646   644
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R F7436000     0   646    642        (NOTLB)     647   645
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R C01DCB90     0   647    642        (NOTLB)     648   646
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R current      0   648    642        (NOTLB)     649   647
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R F746FCB4     0   649    642        (NOTLB)     650   648
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R C0123017     0   650    642        (NOTLB)     651   649
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R F73E2000     0   651    642        (NOTLB)           650
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R F678C000     0   652    639   653  (NOTLB)           642
   sig: 0 0000000000000000 0000000000000000 : X
ipctst    R F6784000  5612   653    652        (NOTLB)
   sig: 0 0000000000000000 0000000000000000 : X
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
