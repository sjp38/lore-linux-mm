Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 829436B025E
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:44:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 2so90873550pfs.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:44:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id hp2si14432578pad.61.2016.09.29.06.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 06:44:03 -0700 (PDT)
Date: Thu, 29 Sep 2016 06:43:57 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH] vfs,mm: fix a dead loop in
 truncate_inode_pages_range()
Message-ID: <20160929134357.GA11463@infradead.org>
References: <1475151010-40166-1-git-send-email-fangwei1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475151010-40166-1-git-send-email-fangwei1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Fang <fangwei1@huawei.com>
Cc: viro@ZenIV.linux.org.uk, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, stable@vger.kernel.org

Can you please add a testcase for this to xfstests?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
