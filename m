Received: by nproxy.gmail.com with SMTP id l23so189642nfc
        for <linux-mm@kvack.org>; Thu, 08 Dec 2005 05:58:46 -0800 (PST)
Message-ID: <84144f020512080558tb9bb6bbjf91e72ad3d9ccaa6@mail.gmail.com>
Date: Thu, 8 Dec 2005 15:58:46 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: allowed pages in the block later, was Re: [Ext2-devel] [PATCH] ext3: avoid sending down non-refcounted pages
In-Reply-To: <20051208134239.GA13376@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051208180900T.fujita.tomonori@lab.ntt.co.jp>
	 <20051208101833.GM14509@schatzie.adilger.int>
	 <20051208134239.GA13376@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, michaelc@cs.wisc.edu, linux-fsdevel@vger.kernel.org, ext2-devel@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On 12/8/05, Christoph Hellwig <hch@infradead.org> wrote:
> One way to work around that would be to detect kmalloced pages and use
> a slowpath for that.  The major issues with that is that we don't have a
> reliable way to detect if a given struct page comes from the slab allocator
> or not.

Why doesn't PageSlab work for you?

                                                          Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
