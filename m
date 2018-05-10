Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0916B05BF
	for <linux-mm@kvack.org>; Thu, 10 May 2018 02:36:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x7-v6so696571wrm.13
        for <linux-mm@kvack.org>; Wed, 09 May 2018 23:36:45 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n5-v6si251497wmf.150.2018.05.09.23.36.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 23:36:44 -0700 (PDT)
Date: Thu, 10 May 2018 08:40:21 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 02/33] fs: factor out a __generic_write_end helper
Message-ID: <20180510064021.GB11422@lst.de>
References: <20180509074830.16196-1-hch@lst.de> <20180509074830.16196-3-hch@lst.de> <20180509151556.GB1313@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509151556.GB1313@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 09, 2018 at 08:15:56AM -0700, Matthew Wilcox wrote:
> On Wed, May 09, 2018 at 09:47:59AM +0200, Christoph Hellwig wrote:
> >  }
> >  EXPORT_SYMBOL(generic_write_end);
> >  
> > +
> >  /*
> 
> Spurious?

Yes.
