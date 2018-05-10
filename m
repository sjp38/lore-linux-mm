Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 609B96B05BD
	for <linux-mm@kvack.org>; Thu, 10 May 2018 02:36:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k27-v6so675876wre.23
        for <linux-mm@kvack.org>; Wed, 09 May 2018 23:36:40 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c133-v6si289923wmh.111.2018.05.09.23.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 23:36:37 -0700 (PDT)
Date: Thu, 10 May 2018 08:40:13 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 01/33] block: add a lower-level bio_add_page interface
Message-ID: <20180510064013.GA11422@lst.de>
References: <20180509074830.16196-1-hch@lst.de> <20180509074830.16196-2-hch@lst.de> <20180509151243.GA1313@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509151243.GA1313@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 09, 2018 at 08:12:43AM -0700, Matthew Wilcox wrote:
> (page, len, off) is a bit weird to me.  Usually we do (page, off, len).

That's what I'd usually do, too.  But this odd convention is what
bio_add_page uses, so I decided to stick to that instead of having two
different conventions in one family of functions.
