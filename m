Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25BFF6B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 21:00:00 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id i8so15144080oih.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 18:00:00 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id o184si11951158oia.38.2016.09.29.17.59.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 17:59:47 -0700 (PDT)
Subject: Re: [RFC][PATCH] vfs,mm: fix a dead loop in
 truncate_inode_pages_range()
References: <1475151010-40166-1-git-send-email-fangwei1@huawei.com>
 <20160929134357.GA11463@infradead.org>
From: Wei Fang <fangwei1@huawei.com>
Message-ID: <57EDB7C1.9040606@huawei.com>
Date: Fri, 30 Sep 2016 08:54:25 +0800
MIME-Version: 1.0
In-Reply-To: <20160929134357.GA11463@infradead.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@ZenIV.linux.org.uk, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, stable@vger.kernel.org

OK, I'll do this.

Thanks,
Wei

On 2016/9/29 21:43, Christoph Hellwig wrote:
> Can you please add a testcase for this to xfstests?
> 
> Thanks!
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
