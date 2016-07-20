Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A20F6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 10:07:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so101624596pfa.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 07:07:08 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id xk1si3581033pac.141.2016.07.20.07.07.05
        for <linux-mm@kvack.org>;
        Wed, 20 Jul 2016 07:07:07 -0700 (PDT)
Message-ID: <578F847E.7070903@huawei.com>
Date: Wed, 20 Jul 2016 22:02:38 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: A question about toot1/vm/page-type.c
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: zhongjiang@huawei.com

Hi,  guys

My system have 4G memory.  I print the following memssage.
I execute the command (page-types) to obtain all pfn status. I check 784272 pfn  about 3063M from page-types ,
but I  ought to obtain all pfn status in the whole memory space, is  right ?  The Memtotal is ~2932M.  therefore,
I guess that page-types do not show the reserved pages from  the following memssage.


[root@localhost vm]# ./page-types
             flags      page-count       MB  symbolic-flags                     long-symbolic-flags
0x0000000000000000           89366      349  __________________________________________
0x0000000001000000               1        0  ________________________z_________________ zero_page
0x0000000000000008              13        0  ___U______________________________________ uptodate
0x000000000000000c               1        0  __RU______________________________________ referenced,uptodate
0x0000000000000028           44175      172  ___U_l____________________________________ uptodate,lru
0x000000000000002c           39128      152  __RU_l____________________________________ referenced,uptodate,lru
0x0000000000004030             876        3  ____Dl________b___________________________ dirty,lru,swapbacked
0x0000000000004038              21        0  ___UDl________b___________________________ uptodate,dirty,lru,swapbacked
0x000000000000403c             124        0  __RUDl________b___________________________ referenced,uptodate,dirty,lru,swapbacked
0x0000000000000068          303508     1185  ___U_lA___________________________________ uptodate,lru,active
0x000000000000006c          146546      572  __RU_lA___________________________________ referenced,uptodate,lru,active
0x0000000000004078              17        0  ___UDlA_______b___________________________ uptodate,dirty,lru,active,swapbacked
0x000000000000407c               4        0  __RUDlA_______b___________________________ referenced,uptodate,dirty,lru,active,swapbacked
0x0000000000000080           97203      379  _______S__________________________________ slab
0x0000000000000228             433        1  ___U_l___I________________________________ uptodate,lru,reclaim
0x0000000000000268             599        2  ___U_lA__I________________________________ uptodate,lru,active,reclaim
0x0000000000000400           36344      141  __________B_______________________________ buddy
0x0000000000000800             673        2  ___________M______________________________ mmap
0x0000000000000804               1        0  __R________M______________________________ referenced,mmap
0x0000000000000828              67        0  ___U_l_____M______________________________ uptodate,lru,mmap
0x000000000000082c             435        1  __RU_l_____M______________________________ referenced,uptodate,lru,mmap
0x0000000000004838             711        2  ___UDl_____M__b___________________________ uptodate,dirty,lru,mmap,swapbacked
0x000000000000483c               1        0  __RUDl_____M__b___________________________ referenced,uptodate,dirty,lru,mmap,swapbacked
0x0000000000000868             224        0  ___U_lA____M______________________________ uptodate,lru,active,mmap
0x000000000000086c            5062       19  __RU_lA____M______________________________ referenced,uptodate,lru,active,mmap
0x0000000000004878             463        1  ___UDlA____M__b___________________________ uptodate,dirty,lru,active,mmap,swapbacked
0x0000000000005048              38        0  ___U__A_____a_b___________________________ uptodate,active,anonymous,swapbacked
0x0000000000401800            3577       13  ___________Ma_________t___________________ mmap,anonymous,thp
0x0000000000005828           10863       42  ___U_l_____Ma_b___________________________ uptodate,lru,mmap,anonymous,swapbacked
0x0000000000405828               2        0  ___U_l_____Ma_b_______t___________________ uptodate,lru,mmap,anonymous,swapbacked,thp
0x000000000000582c              35        0  __RU_l_____Ma_b___________________________ referenced,uptodate,lru,mmap,anonymous,swapbacked
0x0000000000005838               4        0  ___UDl_____Ma_b___________________________ uptodate,dirty,lru,mmap,anonymous,swapbacked
0x000000000040583c               1        0  __RUDl_____Ma_b_______t___________________ referenced,uptodate,dirty,lru,mmap,anonymous,swapbacked,thp
0x0000000000005848              20        0  ___U__A____Ma_b___________________________ uptodate,active,mmap,anonymous,swapbacked
0x0000000000005868            3716       14  ___U_lA____Ma_b___________________________ uptodate,lru,active,mmap,anonymous,swapbacked
0x0000000000405868               4        0  ___U_lA____Ma_b_______t___________________ uptodate,lru,active,mmap,anonymous,swapbacked,thp
0x000000000000586c              16        0  __RU_lA____Ma_b___________________________ referenced,uptodate,lru,active,mmap,anonymous,swapbacked
             total          784272     3063
[root@localhost vm]# cat /proc/meminfo | head -5
MemTotal:        3003168 kB
MemFree:          145228 kB
MemAvailable:    2386420 kB
Buffers:              72 kB
Cached:          2169560 kB
[root@localhost vm]# free -m
              total        used        free      shared  buff/cache   available
Mem:           2932         292         141           8        2498        2330
Swap:         24191           0       24191

In addition , a stupid question that what is the meaning pfn without flag.  the page is allocated by alloc_pages and vmalloc
May be the condition.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
