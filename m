Date: Wed, 4 Jun 2008 11:35:17 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 00/21] hugetlb multi size, giant hugetlb support, etc
Message-ID: <20080604093517.GA32654@wotan.suse.de>
References: <20080603095956.781009952@amd.local0.net> <20080604012938.53b1003c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080604012938.53b1003c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 04, 2008 at 01:29:38AM -0700, Andrew Morton wrote:
> On Tue, 03 Jun 2008 19:59:56 +1000 npiggin@suse.de wrote:
> > 
> > Lastly, embarassingly, I'm not the best source of information for the
> > sysfs tunables, so incremental patches against Documentation/ABI would
> > be welcome :P
> > 
> 
> I think I'll duck this iteration.  Partly because I was unable to work
> out how nacky the feedback for 14/21 was,

I don't think it was at all. At least, any of the suggestions Dave was
making could even be implemented in a backwards compatible way even
after it goes upstream. Basically I'm taking the easy way out when it
comes to user API changes, changing none of the existing interfaces
and just providing very basic boot options.


> but mainly because I don't
> know what it all does, because none of the above explains this.
> 
> Can't review it if I don't know what it's all trying to do.

Fair enough.

 
> Things like this:
> 
> : Large, but rather mechanical patch that converts most of the hugetlb.c
> : globals into structure members and passes them around.
> : 
> : Right now there is only a single global hstate structure, but 
> : most of the infrastructure to extend it is there.
> 
> OK, but it didn't tell us why we want multiple hstate structures.

OK.

 
> : Add basic support for more than one hstate in hugetlbfs
> : 
> : - Convert hstates to an array
> : - Add a first default entry covering the standard huge page size
> : - Add functions for architectures to register new hstates
> : - Add basic iterators over hstates
> 
> And neither did that.
> 
> One for each hugepage size, I'd guess.

Yes.

 
> : Add support to have individual hstates for each hugetlbfs mount
> : 
> : - Add a new pagesize= option to the hugetlbfs mount that allows setting
> : the page size
> : - Set up pointers to a suitable hstate for the set page size option
> : to the super block and the inode and the vma.
> : - Change the hstate accessors to use this information
> : - Add code to the hstate init function to set parsed_hstate for command
> : line processing
> : - Handle duplicated hstate registrations to the make command line user proof
> 
> Nope, wrong guess.  It's one per mountpoint.
 
It is per hugepage size, but each mount point has a pointer to one
of the hstates. Hstate is basically a gathering of most of the
currently global attributes and state in hugetlb and put into a structure.


> So now I'm seeing (I think) that the patchset does indeed implement
> multiple page-size hugepages, and that it it does this by making an
> entire hugetlb mountpoint have a single-but-settable pagesize.

Yes.
 

> All pretty straightforward stuff, unless I'm missing something.  But
> please do spell it out because surely there's stuff in here which I
> will miss from the implementation and the skimpy changelog.
> 
> Please don't think I'm being anal here - changelogging matters.  It
> makes review more effective and it allows reviewers to find problems
> which they would otherwise have overlooked.  btdt, lots of times.

OK, well I'm keen to get it into mm so it's not holding up (or being
busted by) other work... can I just try replying with improved
changelogs? Or do you want me to resend the full series?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
