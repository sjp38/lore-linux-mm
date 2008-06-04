Message-ID: <48468343.2010006@firstfloor.org>
Date: Wed, 04 Jun 2008 13:57:55 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [patch 00/21] hugetlb multi size, giant hugetlb support, etc
References: <20080603095956.781009952@amd.local0.net> <20080604012938.53b1003c.akpm@linux-foundation.org>
In-Reply-To: <20080604012938.53b1003c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

> : Large, but rather mechanical patch that converts most of the hugetlb.c
> : globals into structure members and passes them around.
> : 
> : Right now there is only a single global hstate structure, but 
> : most of the infrastructure to extend it is there.
> 
> OK, but it didn't tell us why we want multiple hstate structures.
> 
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
> 
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

No the initial guess was correct. It's one per size.

> 
> So now I'm seeing (I think) that the patchset does indeed implement
> multiple page-size hugepages, and that it it does this by making an
> entire hugetlb mountpoint have a single-but-settable pagesize.

Correct.

> 
> All pretty straightforward stuff, unless I'm missing something.  But
> please do spell it out because surely there's stuff in here which I
> will miss from the implementation and the skimpy changelog.

It was spelled out in the original 0/0

Here's a copy
ftp://ftp.firstfloor.org/pub/ak/gbpages/patches/intro

> Please don't think I'm being anal here - changelogging matters.  It
> makes review more effective and it allows reviewers to find problems
> which they would otherwise have overlooked.  btdt, lots of times.

Hmm, perhaps we need dummy commits for 0/0s. I guess the intro could
be added to the changelog of the first patch.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
