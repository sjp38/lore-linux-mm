Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 6FCF36B0070
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:17:46 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so12624225qcq.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 13:17:45 -0800 (PST)
Date: Wed, 28 Nov 2012 13:17:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: O_DIRECT on tmpfs (again)
In-Reply-To: <x49ip8rf2yw.fsf@segfault.boston.devel.redhat.com>
Message-ID: <alpine.LNX.2.00.1211281248270.14968@eggly.anvils>
References: <x49ip8rf2yw.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dave Kleikamp <dave.kleikamp@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, 27 Nov 2012, Jeff Moyer wrote:

> Hi Hugh and others,
> 
> In 2007, there were some discussions on whether to allow opens to
> specify O_DIRECT for files backed by tmpfs.[1][2] On the surface, it
> sounds like a completely crazy thing to do.  However, distributions like
> Fedora are now defaulting to using a tmpfs /tmp.  I'm not aware of any
> applications that open temp files using O_DIRECT, but I wanted to get
> some new discussion going on whether this is a reasonable thing to
> expect to work.
> 
> Thoughts?
> 
> Cheers,
> Jeff
> 
> [1] https://lkml.org/lkml/2007/1/4/55
> [2] http://thread.gmane.org/gmane.linux.kernel/482031

Thanks a lot for refreshing my memory with those links.

Whilst I agree with every contradictory word I said back then ;)
my current position is to wait to see what happens with Shaggy's "loop:
Issue O_DIRECT aio using bio_vec" https://lkml.org/lkml/2012/11/22/847

I've been using loop on tmpfs-file in testing for years, and will not
allow that to go away.  I've not yet tried applying the patches and
fixing up mm/shmem.c to suit, but will make sure that it's working
before a release emerges with those changes in.

It would be possible to add nominal O_DIRECT support to tmpfs without
that, and perhaps it would be possible to add that loop support without
enabling O_DIRECT from userspace; but my inclination is to make those
changes together.

(I'm not thinking of doing ramfs and hugetlbfs too.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
