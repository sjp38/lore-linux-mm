Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 706526B0266
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:25:31 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id a202so105113170ybg.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 05:25:31 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id o9si5123106ywj.2.2017.01.24.05.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 05:25:30 -0800 (PST)
Message-ID: <588755AA.7070308@huawei.com>
Date: Tue, 24 Jan 2017 21:24:58 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: [RFC]  pages-type should be updated when page flag have been reused.
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

 
Recently,  I noticed that page flag is reused execssively when bringing  in
supporting non-lru movable.  pages-type analysis the page flags , the
result is not clear.  Therefore,   Do we should updated the file  ?


Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
