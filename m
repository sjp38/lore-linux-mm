Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 14EDE6B0038
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 04:36:30 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so182226023pad.1
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 01:36:29 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id pm10si51670414pac.92.2015.10.26.01.36.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 Oct 2015 01:36:29 -0700 (PDT)
Message-ID: <562DE4E2.2040401@huawei.com>
Date: Mon, 26 Oct 2015 16:31:30 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: memory-hotplug have such a problem.
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: qiuxishi@huawei.com, guohanjun@huawei.com, zhangdianfang@huawei.com



           when I test the memory online or offline, I find the problem that
      memory online always return an error. I peform the operation as follow:

  	cd /sys/device/system/memory/
        echo online > state

 	it always print "-bash: echo: write error: Operation not permitted".
        By my alalysis, I find that the error happen in  the memory_notifier(MEM_GOING_ONLINE,&arg)
        in the function(online_pages()).

        The problem occur in the latest kernel versin (linux 4.3.0 -rc4) , but In the lower version
        (linux 3.10) is correct. I think it may be caused by the confilct.


  	Thanks
	zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
