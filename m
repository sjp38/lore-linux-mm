Date: Fri, 24 Feb 2006 17:27:18 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Fix sys_migrate_pages: Move all pages when invoked from root
In-Reply-To: <20060224171501.1e19d34a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0602241719290.24858@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241616540.24013@schroedinger.engr.sgi.com>
 <20060224164733.6d5224a5.akpm@osdl.org> <Pine.LNX.4.64.0602241649530.24668@schroedinger.engr.sgi.com>
 <20060224171501.1e19d34a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Feb 2006, Andrew Morton wrote:

> Oh, it uses the mapcount rather than a permission check on vma->vm_file. 

Right. The permissions of a file do not determine if a user is 
allowed to move the pages he has from that file. If the user is the sole 
proprietor of a page located in a file where he has no write access 
then he should nevertheless be able to get these pages where he wants 
them to be. Otherwise a processes control over its own address space would
be somewhat limited.

Ray did a lot of work to get this to work right with file permissions in 
earlier years but this ended up with setting special access bits on files 
to determine the migration behavior. We can still do that if there are any 
volunteers that can come up with something that works nicely.

The current approach is IMHO the simplest but it also has some drawbacks. 
F.e. the user may move a page in a critical file before other 
processes have started using it. But at least he cannot move a page that 
is mapped out of position.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
