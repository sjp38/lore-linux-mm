Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC42E6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 13:30:58 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id ba8-v6so3147463plb.4
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:30:58 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e9-v6si1317322pgu.636.2018.06.29.10.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 10:30:56 -0700 (PDT)
Date: Fri, 29 Jun 2018 11:30:55 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v14 68/74] dax: Convert dax_lock_page to XArray
Message-ID: <20180629173055.GA2973@linux.intel.com>
References: <20180617020052.4759-1-willy@infradead.org>
 <20180617020052.4759-69-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180617020052.4759-69-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Sat, Jun 16, 2018 at 07:00:46PM -0700, Matthew Wilcox wrote:
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> ---
<>
> +static void *dax_make_page_entry(struct page *page, void *entry)
> +{
> +	pfn_t pfn = page_to_pfn_t(page);
> +	return dax_make_entry(pfn, dax_is_pmd_entry(entry));
> +}

This function is defined and never used, so we get:

fs/dax.c:106:14: warning: a??dax_make_page_entrya?? defined but not used [-Wunused-function]
 static void *dax_make_page_entry(struct page *page, void *entry)
  ^~~~~~~~~~~~~~~~~~~
