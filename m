Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9AB6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 00:33:18 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b36-v6so9387063pli.2
        for <linux-mm@kvack.org>; Sun, 20 May 2018 21:33:18 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id f2-v6si10755437pgq.444.2018.05.20.21.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 21:33:17 -0700 (PDT)
Date: Sun, 20 May 2018 22:33:15 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v11 52/63] dax: dax_insert_mapping_entry always succeeds
Message-ID: <20180521043315.GB27043@linux.intel.com>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-53-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414141316.7167-53-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Sat, Apr 14, 2018 at 07:13:05AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> It does not return an error, so we don't need to check the return value
> for IS_ERR().
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Yep, this looks correct to me.  You can add:

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
