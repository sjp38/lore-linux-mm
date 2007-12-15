Received: by rv-out-0910.google.com with SMTP id l15so1059727rvb.26
        for <linux-mm@kvack.org>; Fri, 14 Dec 2007 22:47:50 -0800 (PST)
Message-ID: <6934efce0712142247v4de177c2uf956e5fd1bebddf3@mail.gmail.com>
Date: Fri, 14 Dec 2007 22:47:50 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
In-Reply-To: <20071215011712.GA20303@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <47628923.3060706@de.ibm.com>
	 <6934efce0712141707x6aa3d1bevd5ea847262445543@mail.gmail.com>
	 <20071215011712.GA20303@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > One thing I would love is for a way for get_xip_address to be able to
> > punt.  To be able to tell filemap_xip.c functions that the filemap.c
> > or generic functions should be used instead.  For example
> > xip_file_fault() calls filemap_fault() when get_xip_address() returns
> > NULL.  Can we do that for a return value of NULL?
>
> I was thinking about that, but I wonder if it shouldn't be done in
> the filesystem. Eg. if your filesystem mixes both pagecache and XIP,
> then it would call into either filemap or filemap_xip...

Well yeah it can be done in the filesystem.  I just hate to have an
axfs_mmap() that is identical to xip_file_mmap() if it can be avoided.
 Is there some reason not to do the NULL thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
