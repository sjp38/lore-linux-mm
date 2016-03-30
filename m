Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7A90C6B025E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:48:58 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id r72so87173197wmg.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:48:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v19si3455754wjq.20.2016.03.30.00.48.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Mar 2016 00:48:57 -0700 (PDT)
Date: Wed, 30 Mar 2016 09:49:26 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/5] dax: use sb_issue_zerout instead of calling
 dax_clear_sectors
Message-ID: <20160330074926.GC12776@quack.suse.cz>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
 <1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
 <CAPcyv4iKK=1Nhz4QqEkhc4gum+UvUS4a=+Sza2zSa1Kyrth41w@mail.gmail.com>
 <1458939796.5501.8.camel@intel.com>
 <CAPcyv4jWqVcav7dQPh7WHpqB6QDrCezO5jbd9QW9xH3zsU4C1w@mail.gmail.com>
 <1459195288.15523.3.camel@intel.com>
 <CAPcyv4jFwh679arTNoUzLZpJCSoR+KhMdEmwqddCU1RWOrjD=Q@mail.gmail.com>
 <1459277829.6412.3.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1459277829.6412.3.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

On Tue 29-03-16 18:57:16, Verma, Vishal L wrote:
> On Mon, 2016-03-28 at 16:34 -0700, Dan Williams wrote:
> 
> <>
> 
> > Seems kind of sad to fail the fault due to a bad block when we were
> > going to zero it anyway, right?  I'm not seeing a compelling reason to
> > keep any zeroing in fs/dax.c.
> 
> Agreed - but how do we do this? clear_pmem needs to be able to clear an
> arbitrary number of bytes, but to go through the driver, we'd need to
> send down a bio? If only the driver had an rw_bytes like interface that
> could be used by anyone... :)

Actually, my patches for page fault locking remove zeroing from
dax_insert_mapping() and __dax_pmd_fault() - the zeroing now happens from
the filesystem only and the zeroing in those two functions is just a dead
code...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
