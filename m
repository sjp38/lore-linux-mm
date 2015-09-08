Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C3C256B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 02:08:12 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so117537858pac.2
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 23:08:12 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id fx10si3621267pbd.190.2015.09.07.23.08.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 23:08:11 -0700 (PDT)
Message-ID: <1441692486.14597.17.camel@ellerman.id.au>
Subject: Re: [Qemu-devel] [PATCH 19/23] userfaultfd: activate syscall
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 08 Sep 2015 16:08:06 +1000
In-Reply-To: <20150812052346.GC4587@in.ibm.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
	 <1431624680-20153-20-git-send-email-aarcange@redhat.com>
	 <20150811100728.GB4587@in.ibm.com> <20150811134826.GI4520@redhat.com>
	 <20150812052346.GC4587@in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bharata@linux.vnet.ibm.com
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, zhang.zhanghailiang@huawei.com, Pavel Emelyanov <xemul@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andres Lagar-Cavilla <andreslc@google.com>, Mel Gorman <mgorman@suse.de>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Feiner <pfeiner@google.com>, linuxppc-dev@lists.ozlabs.org

On Wed, 2015-08-12 at 10:53 +0530, Bharata B Rao wrote:
> On Tue, Aug 11, 2015 at 03:48:26PM +0200, Andrea Arcangeli wrote:
> > Hello Bharata,
> > 
> > On Tue, Aug 11, 2015 at 03:37:29PM +0530, Bharata B Rao wrote:
> > > May be it is a bit late to bring this up, but I needed the following fix
> > > to userfault21 branch of your git tree to compile on powerpc.
> > 
> > Not late, just in time. I increased the number of syscalls in earlier
> > versions, it must have gotten lost during a rejecting rebase, sorry.
> > 
> > I applied it to my tree and it can be applied to -mm and linux-next,
> > thanks!
> > 
> > The syscall for arm32 are also ready and on their way to the arm tree,
> > the testsuite worked fine there. ppc also should work fine if you
> > could confirm it'd be interesting, just beware that I got a typo in
> > the testcase:
> 
> The testsuite passes on powerpc.
> 
> --------------------
> running userfaultfd
> --------------------
> nr_pages: 2040, nr_pages_per_cpu: 170
> bounces: 31, mode: rnd racing ver poll, userfaults: 80 43 23 23 15 16 12 1 2 96 13 128
> bounces: 30, mode: racing ver poll, userfaults: 35 54 62 49 47 48 2 8 0 78 1 0
> bounces: 29, mode: rnd ver poll, userfaults: 114 153 70 106 78 57 143 92 114 96 1 0
> bounces: 28, mode: ver poll, userfaults: 96 81 5 45 83 19 98 28 1 145 23 2
> bounces: 27, mode: rnd racing poll, userfaults: 54 65 60 54 45 49 1 2 1 2 71 20
> bounces: 26, mode: racing poll, userfaults: 90 83 35 29 37 35 30 42 3 4 49 6
> bounces: 25, mode: rnd poll, userfaults: 52 50 178 112 51 41 23 42 18 99 59 0
> bounces: 24, mode: poll, userfaults: 136 101 83 260 84 29 16 88 1 6 160 57
> bounces: 23, mode: rnd racing ver, userfaults: 141 197 158 183 39 49 3 52 8 3 6 0
> bounces: 22, mode: racing ver, userfaults: 242 266 244 180 162 32 87 43 31 40 34 0
> bounces: 21, mode: rnd ver, userfaults: 636 158 175 24 253 104 48 8 0 0 0 0
> bounces: 20, mode: ver, userfaults: 531 204 225 117 129 107 11 143 76 31 1 0
> bounces: 19, mode: rnd racing, userfaults: 303 169 225 145 59 219 37 0 0 0 0 0
> bounces: 18, mode: racing, userfaults: 374 372 37 144 126 90 25 12 15 17 0 0
> bounces: 17, mode: rnd, userfaults: 313 412 134 108 80 99 7 56 85 0 0 0
> bounces: 16, mode:, userfaults: 431 58 87 167 120 113 98 60 14 8 48 0
> bounces: 15, mode: rnd racing ver poll, userfaults: 41 40 25 28 37 24 0 0 0 0 180 75
> bounces: 14, mode: racing ver poll, userfaults: 43 53 30 28 25 15 19 0 0 0 0 30
> bounces: 13, mode: rnd ver poll, userfaults: 136 91 114 91 92 79 114 77 75 68 1 2
> bounces: 12, mode: ver poll, userfaults: 92 120 114 76 153 75 132 157 83 81 10 1
> bounces: 11, mode: rnd racing poll, userfaults: 50 72 69 52 53 48 46 59 57 51 37 1
> bounces: 10, mode: racing poll, userfaults: 33 49 38 68 35 63 57 49 49 47 25 10
> bounces: 9, mode: rnd poll, userfaults: 167 150 67 123 39 75 1 2 9 125 1 1
> bounces: 8, mode: poll, userfaults: 147 102 20 87 5 27 118 14 104 40 21 28
> bounces: 7, mode: rnd racing ver, userfaults: 305 254 208 74 59 96 36 14 11 7 4 5
> bounces: 6, mode: racing ver, userfaults: 290 114 191 94 162 114 34 6 6 32 23 2
> bounces: 5, mode: rnd ver, userfaults: 370 381 22 273 21 106 17 55 0 0 0 0
> bounces: 4, mode: ver, userfaults: 328 279 179 191 74 86 95 15 13 10 0 0
> bounces: 3, mode: rnd racing, userfaults: 222 215 164 70 5 20 179 0 34 3 0 0
> bounces: 2, mode: racing, userfaults: 316 385 112 160 225 5 30 49 42 2 4 0
> bounces: 1, mode: rnd, userfaults: 273 139 253 176 163 71 85 2 0 0 0 0
> bounces: 0, mode:, userfaults: 165 212 633 13 24 66 24 27 15 0 10 1
> [PASS]

Hmm, not for me. See below.

What setup were you testing on Bharata?

Mine is:

$ uname -a
Linux lebuntu 4.2.0-09705-g3a166acc1432 #2 SMP Tue Sep 8 15:18:00 AEST 2015 ppc64le ppc64le ppc64le GNU/Linux

Which is 7d9071a09502 plus a couple of powerpc patches.

$ zgrep USERFAULTFD /proc/config.gz
CONFIG_USERFAULTFD=y

$ sudo ./userfaultfd 128 32
nr_pages: 2048, nr_pages_per_cpu: 128
bounces: 31, mode: rnd racing ver poll, error mutex 2 2
error mutex 2 10
error mutex 2 15
error mutex 2 21
error mutex 2 22
error mutex 2 27
error mutex 2 36
error mutex 2 39
error mutex 2 40
error mutex 2 41
error mutex 2 43
error mutex 2 75
error mutex 2 79
error mutex 2 83
error mutex 2 100
error mutex 2 108
error mutex 2 110
error mutex 2 114
error mutex 2 119
error mutex 2 120
error mutex 2 135
error mutex 2 137
error mutex 2 141
error mutex 2 142
error mutex 2 144
error mutex 2 145
error mutex 2 150
error mutex 2 151
error mutex 2 159
error mutex 2 161
error mutex 2 169
error mutex 2 172
error mutex 2 174
error mutex 2 175
error mutex 2 176
error mutex 2 178
error mutex 2 188
error mutex 2 194
error mutex 2 208
error mutex 2 210
error mutex 2 212
error mutex 2 220
error mutex 2 223
error mutex 2 224
error mutex 2 226
error mutex 2 236
error mutex 2 249
error mutex 2 252
error mutex 2 255
error mutex 2 256
error mutex 2 267
error mutex 2 277
error mutex 2 284
error mutex 2 295
error mutex 2 302
error mutex 2 306
error mutex 2 307
error mutex 2 308
error mutex 2 318
error mutex 2 319
error mutex 2 320
error mutex 2 323
error mutex 2 324
error mutex 2 341
error mutex 2 344
error mutex 2 345
error mutex 2 353
error mutex 2 357
error mutex 2 359
error mutex 2 372
error mutex 2 379
error mutex 2 396
error mutex 2 399
error mutex 2 419
error mutex 2 431
error mutex 2 433
error mutex 2 438
error mutex 2 439
error mutex 2 443
error mutex 2 445
error mutex 2 454
error mutex 2 460
error mutex 2 469
error mutex 2 474
error mutex 2 481
error mutex 2 490
error mutex 2 496
error mutex 2 504
error mutex 2 509
error mutex 2 512
error mutex 2 515
error mutex 2 517
error mutex 2 523
error mutex 2 527
error mutex 2 529
error mutex 2 531
error mutex 2 540
error mutex 2 544
error mutex 2 546
error mutex 2 548
error mutex 2 552
error mutex 2 553
error mutex 2 562
error mutex 2 564
error mutex 2 566
error mutex 2 583
error mutex 2 584
error mutex 2 587
error mutex 2 591
error mutex 2 594
error mutex 2 595
error mutex 2 606
error mutex 2 609
error mutex 2 612
error mutex 2 619
error mutex 2 620
error mutex 2 625
error mutex 2 630
error mutex 2 640
error mutex 2 642
error mutex 2 647
error mutex 2 649
error mutex 2 652
error mutex 2 655
error mutex 2 661
error mutex 2 662
error mutex 2 666
error mutex 2 668
error mutex 2 670
error mutex 2 673
error mutex 2 679
error mutex 2 693
error mutex 2 703
error mutex 2 704
error mutex 2 707
error mutex 2 710
error mutex 2 712
error mutex 2 713
error mutex 2 715
error mutex 2 724
error mutex 2 727
error mutex 2 733
error mutex 2 735
error mutex 2 738
error mutex 2 742
error mutex 2 743
error mutex 2 745
error mutex 2 747
error mutex 2 753
error mutex 2 755
error mutex 2 766
error mutex 2 773
error mutex 2 774
error mutex 2 775
error mutex 2 776
error mutex 2 786
error mutex 2 787
error mutex 2 790
error mutex 2 794
error mutex 2 797
error mutex 2 801
error mutex 2 803
error mutex 2 804
error mutex 2 805
error mutex 2 817
error mutex 2 820
error mutex 2 823
error mutex 2 824
error mutex 2 828
error mutex 2 832
error mutex 2 834
error mutex 2 836
error mutex 2 838
error mutex 2 839
error mutex 2 841
error mutex 2 850
error mutex 2 851
error mutex 2 857
error mutex 2 866
error mutex 2 868
error mutex 2 872
error mutex 2 879
error mutex 2 889
error mutex 2 890
error mutex 2 892
error mutex 2 893
error mutex 2 896
error mutex 2 903
error mutex 2 906
error mutex 2 907
error mutex 2 910
error mutex 2 911
error mutex 2 915
error mutex 2 916
error mutex 2 917
error mutex 2 922
error mutex 2 930
error mutex 2 933
error mutex 2 937
error mutex 2 945
error mutex 2 953
error mutex 2 962
error mutex 2 971
error mutex 2 986
error mutex 2 993
error mutex 2 1004
error mutex 2 1011
error mutex 2 1029
error mutex 2 1032
error mutex 2 1038
error mutex 2 1047
error mutex 2 1052
error mutex 2 1057
error mutex 2 1061
error mutex 2 1065
error mutex 2 1069
error mutex 2 1084
error mutex 2 1086
error mutex 2 1087
error mutex 2 1091
error mutex 2 1098
error mutex 2 1107
error mutex 2 1113
error mutex 2 1114
error mutex 2 1120
error mutex 2 1122
error mutex 2 1127
error mutex 2 1131
error mutex 2 1135
error mutex 2 1137
error mutex 2 1142
error mutex 2 1144
error mutex 2 1150
error mutex 2 1152
error mutex 2 1156
error mutex 2 1157
error mutex 2 1166
error mutex 2 1183
error mutex 2 1186
error mutex 2 1187
error mutex 2 1199
error mutex 2 1200
error mutex 2 1209
error mutex 2 1213
error mutex 2 1223
error mutex 2 1226
error mutex 2 1239
error mutex 2 1244
error mutex 2 1273
error mutex 2 1280
error mutex 2 1289
error mutex 2 1296
error mutex 2 1301
error mutex 2 1304
error mutex 2 1305
error mutex 2 1311
error mutex 2 1314
error mutex 2 1318
error mutex 2 1319
error mutex 2 1321
error mutex 2 1323
error mutex 2 1325
error mutex 2 1331
error mutex 2 1335
error mutex 2 1348
error mutex 2 1354
error mutex 2 1355
error mutex 2 1359
error mutex 2 1360
error mutex 2 1371
error mutex 2 1372
error mutex 2 1373
error mutex 2 1379
error mutex 2 1382
error mutex 2 1401
error mutex 2 1403
error mutex 2 1411
error mutex 2 1419
error mutex 2 1420
error mutex 2 1422
error mutex 2 1423
error mutex 2 1426
error mutex 2 1432
error mutex 2 1442
error mutex 2 1445
error mutex 2 1446
error mutex 2 1447
error mutex 2 1453
error mutex 2 1455
error mutex 2 1457
error mutex 2 1458
error mutex 2 1459
error mutex 2 1460
error mutex 2 1461
error mutex 2 1468
error mutex 2 1469
error mutex 2 1470
error mutex 2 1475
error mutex 2 1478
error mutex 2 1484
error mutex 2 1488
error mutex 2 1490
error mutex 2 1491
error mutex 2 1498
error mutex 2 1505
error mutex 2 1511
error mutex 2 1517
error mutex 2 1520
error mutex 2 1522
error mutex 2 1526
error mutex 2 1531
error mutex 2 1535
error mutex 2 1542
error mutex 2 1546
error mutex 2 1559
error mutex 2 1566
error mutex 2 1572
error mutex 2 1574
error mutex 2 1581
error mutex 2 1584
error mutex 2 1592
error mutex 2 1600
error mutex 2 1604
error mutex 2 1605
error mutex 2 1607
error mutex 2 1611
error mutex 2 1618
error mutex 2 1624
error mutex 2 1628
error mutex 2 1631
error mutex 2 1632
error mutex 2 1633
error mutex 2 1640
error mutex 2 1647
error mutex 2 1650
error mutex 2 1651
error mutex 2 1652
error mutex 2 1654
error mutex 2 1656
error mutex 2 1657
error mutex 2 1658
error mutex 2 1659
error mutex 2 1661
error mutex 2 1671
error mutex 2 1675
error mutex 2 1678
error mutex 2 1680
error mutex 2 1687
error mutex 2 1688
error mutex 2 1701
error mutex 2 1704
error mutex 2 1706
error mutex 2 1711
error mutex 2 1716
error mutex 2 1722
error mutex 2 1727
error mutex 2 1728
error mutex 2 1742
error mutex 2 1754
error mutex 2 1755
error mutex 2 1757
error mutex 2 1763
error mutex 2 1772
error mutex 2 1783
error mutex 2 1784
error mutex 2 1789
error mutex 2 1792
error mutex 2 1800
error mutex 2 1814
error mutex 2 1817
error mutex 2 1830
error mutex 2 1833
error mutex 2 1837
error mutex 2 1851
error mutex 2 1852
error mutex 2 1855
error mutex 2 1858
error mutex 2 1859
error mutex 2 1865
error mutex 2 1873
error mutex 2 1877
error mutex 2 1887
error mutex 2 1889
error mutex 2 1891
error mutex 2 1895
error mutex 2 1909
error mutex 2 1910
error mutex 2 1915
error mutex 2 1917
error mutex 2 1921
error mutex 2 1930
error mutex 2 1944
error mutex 2 1947
error mutex 2 1962
error mutex 2 1963
error mutex 2 1964
error mutex 2 1975
error mutex 2 1977
error mutex 2 1979
error mutex 2 1980
error mutex 2 1982
error mutex 2 1987
error mutex 2 1990
error mutex 2 1991
error mutex 2 1992
error mutex 2 1996
error mutex 2 2005
error mutex 2 2007
error mutex 2 2009
error mutex 2 2012
error mutex 2 2017
error mutex 2 2030
error mutex 2 2034
error mutex 2 2039
error mutex 2 2041
error mutex 2 2045
userfaults: 200 46 78 60 64 47 41 38 22 28 15 16 20 4 5 0
$ echo $?
0

So it claims to have passed, but all those errors make me think otherwise?

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
