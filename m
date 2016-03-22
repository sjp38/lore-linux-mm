Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 37E7F6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 09:59:27 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id n5so312781374pfn.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 06:59:27 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id sm8si2565261pac.13.2016.03.22.06.59.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Mar 2016 06:59:26 -0700 (PDT)
Message-ID: <56F14EEE.7060308@huawei.com>
Date: Tue, 22 Mar 2016 21:55:58 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] mm: why cat /proc/pid/smaps | grep Rss is different from cat
 /proc/pid/statm?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

[root@localhost c_test]# cat /proc/3948/smaps | grep Rss
Rss:                   4 kB
Rss:                   4 kB
Rss:                   4 kB
Rss:                 796 kB
Rss:                   0 kB
Rss:                  16 kB
Rss:                   8 kB
Rss:                  12 kB
Rss:                 132 kB
Rss:                  12 kB
Rss:                   4 kB
Rss:                   4 kB
Rss:                   4 kB
Rss:                   4 kB
Rss:                  12 kB
Rss:                   0 kB
Rss:                   4 kB
Rss:                   0 kB
[root@localhost c_test]# cat /proc/3948/statm
1042 173 154 1 0 48 0

173 means Rss is 173*4kb=692kb, right?
so why it is different from the sum(1020kb) of "cat /proc/pid/smaps | grep Rss"?

my test code is
...
int main()
{
	sleep(1000);
	return 0;
}

the kernel version is v4.1

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
