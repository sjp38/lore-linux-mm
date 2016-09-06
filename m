Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6DCE6B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 09:20:05 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 74so6144793oie.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 06:20:05 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id l6si998195oih.124.2016.09.06.06.19.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 06:19:56 -0700 (PDT)
Message-ID: <57CEC199.9000501@huawei.com>
Date: Tue, 6 Sep 2016 21:16:09 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mem-hotplug: Don't clear the only node in new_node_page()
References: <1473044391.4250.19.camel@TP420>
In-Reply-To: <1473044391.4250.19.camel@TP420>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, jallen@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>

On 2016/9/5 10:59, Li Zhong wrote:

> Commit 394e31d2c introduced new_node_page() for memory hotplug. 
> 
> In new_node_page(), the nid is cleared before calling __alloc_pages_nodemask().
> But if it is the only node of the system, and the first round allocation fails,
> it will not be able to get memory from an empty nodemask, and trigger oom. 
> 

Hi,

Yes, I missed this case, thanks for your fix.

Thanks,
Xishi Qiu

> The patch checks whether it is the last node on the system, and if it is, then
> don't clear the nid in the nodemask.
> 
> Reported-by: John Allen <jallen@linux.vnet.ibm.com>
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
