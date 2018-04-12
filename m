Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7F006B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:22:17 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o33-v6so3910981plb.16
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 07:22:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s66si2294782pgb.59.2018.04.12.07.22.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 07:22:16 -0700 (PDT)
Date: Thu, 12 Apr 2018 16:22:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mmap.2: Add description of MAP_SHARED_VALIDATE and
 MAP_SYNC
Message-ID: <20180412142214.fcxw3g2jxv6bvn7d@quack2.suse.cz>
References: <20171101153648.30166-1-jack@suse.cz>
 <20171101153648.30166-20-jack@suse.cz>
 <CAKgNAkhsFrcdkXNA2cw3o0gJV0uLRtBg9ybaCe5xy1QBC2PgqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgNAkhsFrcdkXNA2cw3o0gJV0uLRtBg9ybaCe5xy1QBC2PgqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Ext4 Developers List <linux-ext4@vger.kernel.org>, xfs <linux-xfs@vger.kernel.org>, "Darrick J . Wong" <darrick.wong@oracle.com>

Hello Michael!

On Thu 12-04-18 15:00:49, Michael Kerrisk (man-pages) wrote:
> Hello Jan,
> 
> I have applied your patch, and tweaked the text a little, and pushed
> the result to the git repo.

Thanks!

> > +.B MAP_SHARED
> > +type will silently ignore this flag.
> > +This flag is supported only for files supporting DAX (direct mapping of persistent
> > +memory). For other files, creating mapping with this flag results in
> > +.B EOPNOTSUPP
> > +error. Shared file mappings with this flag provide the guarantee that while
> > +some memory is writeably mapped in the address space of the process, it will
> > +be visible in the same file at the same offset even after the system crashes or
> > +is rebooted. This allows users of such mappings to make data modifications
> > +persistent in a more efficient way using appropriate CPU instructions.
> 
> It feels like there's a word missing/unclear wording in the previous
> line, before "using". Without that word, the sentence feels a bit
> ambiguous.
> 
> Should it be:
> 
> persistent in a more efficient way *through the use of* appropriate
> CPU instructions.
> 
> or:
> 
> persistent in a more efficient way *than using* appropriate CPU instructions.
> 
> ?
> 
> Is suspect the first is correct, but need to check.

Yes, the first is correct.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
