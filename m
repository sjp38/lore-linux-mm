Message-Id: <20080603095956.781009952@amd.local0.net>
Date: Tue, 03 Jun 2008 19:59:56 +1000
From: npiggin@suse.de
Subject: [patch 00/21] hugetlb multi size, giant hugetlb support, etc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Hi,

Here is my submission to be merged in -mm. Given the amount of hunks this
patchset has, and the recent flurry of hugetlb development work, I'd hope to
get this merged up provided there aren't major issues (I would prefer to fix
minor ones with incremental patches). It's just a lot of error prone work to
track -mm when multiple concurrent development is happening.

Patch against latest mmotm.


What I have done for the user API issues with this release is to take the
safe way out and just maintain the existing hugepages user interfaces
unchanged. I've integrated Nish's sysfs API to control the other huge
page sizes.

I had initially opted to drop the /proc/sys/vm/* parts of the changes, but
I found that the libhugetlbfs suite continued to have failures, so I
decided to revert the multi column /proc/meminfo changes too, for now.

I say for now, because it is very easy to subsequently agree on some
extention to the API, but it is much harder to revert such an extention once
it has been made. I also think the main thing at this point is to get the
existing patchset merged. User API changes I really don't want to worry
with at the moment... point is: the infrastructure changes are a lot of
work to code, but not so hard to get right; the user API changes are
easy to code but harder to get right.

New to this patchset: I have implemented a default_hugepagesz= boot option
(defaulting to the arch's HPAGE_SIZE if unspecified), which can be used to
specify the default hugepage size for all /proc/* files, SHM, and default
hugetlbfs mount size. This is the best compromise I could find to keep back
compatibility while allowing the possibility to try different sizes with
legacy code.

One thing I worry about is whether the sysfs API is going to be foward
compatible with NUMA allocation changes that might be in the pipe.
This need not hold up a merge into -mm, but I'd like some reassurances
that thought is put in before it goes upstream.

Lastly, embarassingly, I'm not the best source of information for the
sysfs tunables, so incremental patches against Documentation/ABI would
be welcome :P

Thanks,
Nick
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
