Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 42D676B007E
	for <linux-mm@kvack.org>; Thu, 12 May 2016 23:58:36 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so32495073lfq.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 20:58:36 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id tp3si6162993wjb.175.2016.05.12.20.58.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 May 2016 20:58:35 -0700 (PDT)
Message-ID: <573550D8.9030507@huawei.com>
Date: Fri, 13 May 2016 11:58:16 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: why the count nr_file_pages is not equal to nr_inactive_file + nr_active_file
 ?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

I find the count nr_file_pages is not equal to nr_inactive_file + nr_active_file.
There are 8 cpus, 2 zones in my system.

I think may be the pagevec trigger the problem, but PAGEVEC_SIZE is only 14.
Does anyone know the reason?

Thanks,
Xishi Qiu

root@hi3650:/ # cat /proc/vmstat 
nr_free_pages 54192
nr_inactive_anon 39830
nr_active_anon 28794
nr_inactive_file 432444
nr_active_file 20659
nr_unevictable 2363
nr_mlock 0
nr_anon_pages 65249
nr_mapped 19742
nr_file_pages 462723
nr_dirty 20
nr_writeback 0
...


nr_inactive_file 432444
nr_active_file 20659
total is 453103

nr_file_pages 462723

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
