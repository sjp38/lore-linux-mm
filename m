Date: Wed, 30 May 2007 10:57:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: numa_maps display of shmem--need/want '\040(deleted)' ???
In-Reply-To: <1180544557.5850.78.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705301056370.1195@schroedinger.engr.sgi.com>
References: <1180544557.5850.78.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2007, Lee Schermerhorn wrote:

> While I'm looking at numa_maps, do we need/want that funky suffix string
> that shows up on the file names of shmem regions in numa_maps?  I expect
> it will show up on any unlinked, mmap'ed file, but haven't tested that
> case.  Is it useful information in the context of numa_maps?
> 
> Maybe translate the '\040' back to a space?

Sorry I am not that familiar with shmem ....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
