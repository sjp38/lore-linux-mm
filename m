Received: by nz-out-0506.google.com with SMTP id i11so881492nzh.26
        for <linux-mm@kvack.org>; Fri, 14 Dec 2007 17:07:39 -0800 (PST)
Message-ID: <6934efce0712141707x6aa3d1bevd5ea847262445543@mail.gmail.com>
Date: Fri, 14 Dec 2007 17:07:38 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
In-Reply-To: <47628923.3060706@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <47628923.3060706@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Nick Piggin wrote:
> > This is just a prototype for one possible way of supporting this. I may
> > be missing some important detail or eg. have missed some requirement of the
> > s390 XIP block device that makes the idea infeasible... comments?
> Seems to be christmas time, I get a feature that has been on my most
> wanted list for years :-). Will play with it and test it asap :-).

That's exactly how I feel.  I'm testing it out right now.

One thing I would love is for a way for get_xip_address to be able to
punt.  To be able to tell filemap_xip.c functions that the filemap.c
or generic functions should be used instead.  For example
xip_file_fault() calls filemap_fault() when get_xip_address() returns
NULL.  Can we do that for a return value of NULL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
