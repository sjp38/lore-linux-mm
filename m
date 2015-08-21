Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6A92C6B0254
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 05:30:04 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so11118724wid.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 02:30:04 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id s19si3276146wiv.7.2015.08.21.02.30.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Aug 2015 02:30:03 -0700 (PDT)
Message-ID: <55D6EEEB.7050701@huawei.com>
Date: Fri, 21 Aug 2015 17:27:07 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: is this a problem of numactl in RedHat7.0 ?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>

I use numactl(--localalloc) tool run a test case, but it shows that
the numa policy is prefer, I don't know why.

[root@localhost test]# numactl --hard
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 12 13 14 15 16 17
node 0 size: 32739 MB
node 0 free: 29134 MB
node 1 cpus: 6 7 8 9 10 11 18 19 20 21 22 23
node 1 size: 32768 MB
node 1 free: 31682 MB
node distances:
node   0   1
  0:  10  20
  1:  20  10

[root@localhost test]# numactl --localalloc --physcpubind=22 ./test.exe

[root@localhost linux-3.10-redhat]# ps -ef| grep test
root      18532  13994  1 05:24 pts/0    00:00:00 ./test.exe
root      18534  14037  0 05:24 pts/1    00:00:00 grep --color=auto test
[root@localhost linux-3.10-redhat]# cat /proc/18532/numa_maps
00400000 prefer:0 file=/home/qiuxishi/test/test.exe mapped=1 N0=1
00600000 prefer:0 file=/home/qiuxishi/test/test.exe anon=1 dirty=1 N1=1
00601000 prefer:0 file=/home/qiuxishi/test/test.exe anon=1 dirty=1 N1=1
7f1a15b9b000 prefer:0 file=/usr/lib64/libc-2.17.so mapped=51 mapmax=44 N0=49 N1=2
7f1a15d51000 prefer:0 file=/usr/lib64/libc-2.17.so
7f1a15f51000 prefer:0 file=/usr/lib64/libc-2.17.so anon=4 dirty=4 N1=4
7f1a15f55000 prefer:0 file=/usr/lib64/libc-2.17.so anon=2 dirty=2 N1=2
7f1a15f57000 prefer:0 anon=3 dirty=3 N1=3
7f1a15f5c000 prefer:0 file=/usr/lib64/ld-2.17.so mapped=28 mapmax=15 N0=23 N1=5
7f1a16166000 prefer:0 anon=3 dirty=3 N1=3
7f1a1617c000 prefer:0 anon=1 dirty=1 N1=1
7f1a1617d000 prefer:0 file=/usr/lib64/ld-2.17.so anon=1 dirty=1 N1=1
7f1a1617e000 prefer:0 file=/usr/lib64/ld-2.17.so anon=1 dirty=1 N1=1
7f1a1617f000 prefer:0 anon=1 dirty=1 N1=1
7ffd0d2ed000 prefer:0 stack anon=3 dirty=3 N1=3
7ffd0d3fc000 prefer:0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
