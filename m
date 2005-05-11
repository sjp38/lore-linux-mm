Message-ID: <4282798F.8060005@engr.sgi.com>
Date: Wed, 11 May 2005 16:30:55 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> <20050511195003.GA2468@infradead.org>
In-Reply-To: <20050511195003.GA2468@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:

> 
> But it's the right thing to do.  Non-migratability is not an attribute
> of a file but a memory region.  Being able to set it for individual
> mappings and possible even modifying it with a new MADVISE subcall
> makes sense.
> 
> 

I guess we have a different world view on this.  It seems to me that
migratability is a long term property of the file itself (and how it
is commonly used) rather than a short term property (i. e. how the
file is used this particular time it got mapped in).

It seems to me the system administrator needs the ability to specify
that certain files, based on long term usage patterns in the system,
should be treated as migratable libraries or non-migratable files.
(It may be the case that certain shared libraries are so infrequently
used that they can be migrated with a process, I suppose.)

So I think the natural place to put this information is in the file
system.  That doesn't mean that a new MADVISE() call isn't useful,
it's just that I don't want to have to make this call every time
the file is mapped.

Hiding this call in ld-linux.so would probably be ok provided we can
get the glibc developers to buy off on such a change.  I'd much
prefer to contain the changes in one open source project rather than
two.  :-)  Similarly, having to create a new command to mark files
as migratable/not, rather than using the existing setfattr/getfattr
commands makes the whole memory migration facility that much harder
to get accepted into the system and to use.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
