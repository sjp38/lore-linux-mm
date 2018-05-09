Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3812D6B052E
	for <linux-mm@kvack.org>; Wed,  9 May 2018 11:46:55 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 72-v6so3936909pld.19
        for <linux-mm@kvack.org>; Wed, 09 May 2018 08:46:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 132-v6si10012859pgb.674.2018.05.09.08.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 08:46:54 -0700 (PDT)
Date: Wed, 9 May 2018 08:46:52 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 07/33] mm: split ->readpages calls to avoid
 non-contiguous pages lists
Message-ID: <20180509154652.GE1313@bombadil.infradead.org>
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509074830.16196-8-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 09, 2018 at 09:48:04AM +0200, Christoph Hellwig wrote:
> That way file systems don't have to go spotting for non-contiguous pages
> and work around them.  It also kicks off I/O earlier, allowing it to
> finish earlier and reduce latency.

Makes sense.

> +			/*
> +			 * Page already present?  Kick off the current batch of
> +			 * contiguous pages before continueing with the next

"continuing" (no 'e')
