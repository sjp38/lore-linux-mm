Date: Sat, 5 Apr 2003 04:24:54 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030405022454.GN16293@dualathlon.random>
References: <Pine.LNX.4.44.0304041453160.1708-100000@localhost.localdomain> <20030404105417.3a8c22cc.akpm@digeo.com> <20030404214547.GB16293@dualathlon.random> <20030404150744.7e213331.akpm@digeo.com> <20030405000352.GF16293@dualathlon.random> <20030404163154.77f19d9e.akpm@digeo.com> <20030405013143.GJ16293@dualathlon.random> <20030404180620.4677b966.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030404180620.4677b966.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 04, 2003 at 06:06:20PM -0800, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> >
> > > - get_unmapped_area() search complexity.
> > > 
> > >   Solved by remap_file_pages and by as-yet unimplemented algorithmic rework.
> > 
> > what is this "yet unimplemented algorithmic rework".
> 
> I was referring to your planned mmap speedup.  I should have said 'or', nor
> 'and'.

Oh I see, thanks for the clarification. My plan was to do it only for
mmap, not to let it work for remap_file_pages too to avoid any
additional kernel complexity. I think remap_file_pages (if it stays)
should be a magic for 32bit archs to allow mangling the pagetables from
userspace, so I'm not very interested to mix the mmap layer in any way
with it (more than teaching all MM functions to stay away from a
VM_NONLINEAR vma).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
