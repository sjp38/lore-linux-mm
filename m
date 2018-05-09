Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9326B0528
	for <linux-mm@kvack.org>; Wed,  9 May 2018 11:15:59 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f10-v6so3886794pln.21
        for <linux-mm@kvack.org>; Wed, 09 May 2018 08:15:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 62-v6si26010416pld.133.2018.05.09.08.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 08:15:58 -0700 (PDT)
Date: Wed, 9 May 2018 08:15:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 02/33] fs: factor out a __generic_write_end helper
Message-ID: <20180509151556.GB1313@bombadil.infradead.org>
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509074830.16196-3-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 09, 2018 at 09:47:59AM +0200, Christoph Hellwig wrote:
>  }
>  EXPORT_SYMBOL(generic_write_end);
>  
> +
>  /*

Spurious?
