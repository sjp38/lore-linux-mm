Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50DCB6B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 00:24:12 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so13367370pgv.5
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 21:24:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l4si10625556plt.419.2017.12.04.21.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 21:24:10 -0800 (PST)
Date: Mon, 4 Dec 2017 21:24:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] dax: fix potential overflow on 32bit machine
Message-ID: <20171205052407.GA20757@bombadil.infradead.org>
References: <20171205033210.38338-1-yi.zhang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205033210.38338-1-yi.zhang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhangyi (F)" <yi.zhang@huawei.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, viro@zeniv.linux.org.uk, miaoxie@huawei.com

On Tue, Dec 05, 2017 at 11:32:10AM +0800, zhangyi (F) wrote:
> On 32bit machine, when mmap2 a large enough file with pgoff more than
> ULONG_MAX >> PAGE_SHIFT, it will trigger offset overflow and lead to
> unmap the wrong page in dax_insert_mapping_entry(). This patch cast
> pgoff to 64bit to prevent the overflow.

You're quite correct, and you've solved this problem the same way as the
other half-dozen users in the kernel with the problem, so good job.

I think we can do better though.  How does this look?
