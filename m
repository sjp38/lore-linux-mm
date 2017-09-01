Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36B3F6B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 03:34:08 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u15so8507139pgb.7
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 00:34:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d9si1428367pge.780.2017.09.01.00.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Sep 2017 00:34:07 -0700 (PDT)
Date: Fri, 1 Sep 2017 00:34:02 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] mm: introduce MAP_VALIDATE, a mechanism for for
 safely defining new mmap flags
Message-ID: <20170901073402.GA19080@infradead.org>
References: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150413450616.5923.7069852068237042023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170831100359.GD21443@lst.de>
 <CAPcyv4jvTB4Aiei1-fGybyJNopXQy9zADpnFcuRNdZCS4Mf1QQ@mail.gmail.com>
 <CA+55aFwsfUj1f41w8hqt9LN3-ajmJ=2AB1Nb6ZzwHgE1OKxGOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwsfUj1f41w8hqt9LN3-ajmJ=2AB1Nb6ZzwHgE1OKxGOw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 31, 2017 at 06:27:31PM -0700, Linus Torvalds wrote:
> Why? That's no different from the case statement for the mmu case,
> just written differently.

Yes.

> You *want* existing kernels to fail, since they don't test the bits
> you want to test.
> 
> So you just want to rewrite these all as
> 
>     switch (flags & MAP_TYPE) {
>     case MAP_SHARED_VALIDATE:
>         .. validate the other bits...
>         /* fallhtough */
>     case MAP_SHARED:
>         .. do the shared case ..
>     case MAP_PRIVATE:
>         .. do the private case ..
>     default:
>         return -EINVAL;
>     }

Btw, at least my original idea was to make MAP_VALIDATE a flag
instead of another mapping type, that is take it out of MAP_TYPE.

That being said this version is ok with me too - the chances of
needing a new type of private mappings probably isn't too big.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
