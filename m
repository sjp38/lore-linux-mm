Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80A1A6B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 09:04:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l21-v6so2738385pff.3
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 06:04:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e1-v6si8661647pfg.257.2018.07.06.06.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Jul 2018 06:04:11 -0700 (PDT)
Date: Fri, 6 Jul 2018 06:04:07 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v14 68/74] dax: Convert dax_lock_page to XArray
Message-ID: <20180706130407.GA18395@bombadil.infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
 <20180617020052.4759-69-willy@infradead.org>
 <20180629173055.GA2973@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180629173055.GA2973@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Fri, Jun 29, 2018 at 11:30:55AM -0600, Ross Zwisler wrote:
> On Sat, Jun 16, 2018 at 07:00:46PM -0700, Matthew Wilcox wrote:
> > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > ---
> <>
> > +static void *dax_make_page_entry(struct page *page, void *entry)
> > +{
> > +	pfn_t pfn = page_to_pfn_t(page);
> > +	return dax_make_entry(pfn, dax_is_pmd_entry(entry));
> > +}
> 
> This function is defined and never used, so we get:
> 
> fs/dax.c:106:14: warning: a??dax_make_page_entrya?? defined but not used [-Wunused-function]
>  static void *dax_make_page_entry(struct page *page, void *entry)
>   ^~~~~~~~~~~~~~~~~~~

Yeah, it was used in one of the functions Dan added, then removed.
I understand he's planning on bringing that back before 4.19 and I'm
going to rebase on top of that, so I've left it there for now.
