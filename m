From: Andi Kleen <ak@suse.de>
Subject: Re: Query re:  mempolicy for page cache pages
Date: Thu, 18 May 2006 20:12:19 +0200
References: <1147974599.5195.96.camel@localhost.localdomain>
In-Reply-To: <1147974599.5195.96.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605182012.19570.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Steve Longerbeam <stevel@mvista.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> 1) What ever happened to Steve's patch set?

It needed more work, but he just disappeared at some point.



> 
> 2) Is this even a problem that needs solving, as Christoph seem to think
> at one time?

The problem that hasn't been worked out is how to add persistent 
attributes to files. Steve avoided that by limiting his to only
ELF executables and using a static header there, but i'm not
sure that is a generally useful enough for mainline. Just temporary
for mmaps seems very narrow in usefulness.

And with xattrs was unclear if it would be costly or not and
even worth it.

At least in the general case just interleaving the file cache
based on a global setting or on cpuset seemed to work well enough
for most people.

Let's ask it differently. Do you have a real application that
would be improved by it? 


> 2) As with shmem segments, the shared policies applied to shared
>    file mappings persist as long as the inode remains--i.e., until
>    the file is deleted or the inode recycled--whether or not any
>    task has the file mapped or even open.  We could, I suppose,
>    free the map on last close.

The recycling is the problem. It's basically a lottery if the
attributes are kept with high memory pressure or not.
Doesn't seem like a robust approach.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
