Message-Id: <200510100651.j9A6pZg13871@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: FW: [PATCH 0/3] Demand faulting for huge pages
Date: Sun, 9 Oct 2005 23:51:11 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.61.0510091306440.7878@goblin.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>
Cc: "Seth, Rohit" <rohit.seth@intel.com>, William Irwin <wli@holomorphy.com>, agl@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote on Sunday, October 09, 2005 5:27 AM
> We all seem
> to have different agendas for hugetlb.  I'm interested in fixing the
> existing bugs with truncation (see -mm), and getting the locking to
> fit with my page_table_lock patches.  Prohibiting truncation is an
> attractively easy and efficient way of fixing several such problems.
> Adam is interested in fault on demand, which needs further work if
> truncation is allowed.  You and Rohit are interested in enhancing
> the generality of hugetlbfs.

IMO, these three things are not contradictory with each other.  They
are orthogonal.  Even though maybe we are all touching same lines of
code, in the end, everyone is working toward better and more robust
hugetlb code.

Demand paging is one aspect of enhancing generality of hugetlb.  Intel
initially proposed the feature 18 month ago [* see link below] along
with SGI. Christoph Lameter at SGI scratched that subject Oct 2004.
And now, Adam at IBM attempts it again.  There is a growing need to
make hugetlb easier to use, more transparency in using hugetlb pages
etc.  All requires hugetlb code to be more generalized, instead of
reducing functionality.

Granted, the patch I posted on expanding ftruncate will be replaced
once demand paging goes in.  I wanted to demonstrate that it is a
feature we should implement, instead of cutting back more on current
thin functionality in hugetlbfs. (with demand paging, expanding
ftruncate should be really easy and clean, instead of "peculiar
semantics" all because of prefaulting).

- Ken

[*] http://marc.theaimsgroup.com/?l=linux-ia64&m=108189860401704&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
