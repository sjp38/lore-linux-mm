Date: Sun, 9 Oct 2005 13:27:29 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: RE: FW: [PATCH 0/3] Demand faulting for huge pages
In-Reply-To: <200510080758.j987w0g06343@unix-os.sc.intel.com>
Message-ID: <Pine.LNX.4.61.0510091306440.7878@goblin.wat.veritas.com>
References: <200510080758.j987w0g06343@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: "Seth, Rohit" <rohit.seth@intel.com>, William Irwin <wli@holomorphy.com>, agl@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Oct 2005, Chen, Kenneth W wrote:
> Rohit Seth wrote on Friday, October 07, 2005 2:29 PM
> > On Fri, 2005-10-07 at 10:47 -0700, Adam Litke wrote:
> > > If I were to spend time coding up a patch to remove truncation
> > > support for hugetlbfs, would it be something other people would
> > > want to see merged as well?
> > 
> > In its current form, there is very little use of huegtlb truncate
> > functionality.  Currently it only allows reducing the size of hugetlb
> > backing file.   

And is that functionality actually used?

> > IMO it will be useful to keep and enhance this capability so that
> > apps can dynamically reduce or increase the size of backing files
> > (for example based on availability of memory at any time).

And is that functionality actually being asked for?

> Yup, here is a patch to enhance that capability.  It is more of bring
> ftruncate on hugetlbfs file a step closer to the same semantics for
> file on other file systems.

Well, it's peculiar semantics that extending a file slots its pages
into existing mmaps, as in your patch.  Though that may indeed match
the existing prefault semantics for hugetlb mmaps and files.  But in
those existing peculiar semantics, the file can already be extended,
by mmaping further, so you're not really adding new capability.

But please don't expect me to decide one way or another.  We all seem
to have different agendas for hugetlb.  I'm interested in fixing the
existing bugs with truncation (see -mm), and getting the locking to
fit with my page_table_lock patches.  Prohibiting truncation is an
attractively easy and efficient way of fixing several such problems.
Adam is interested in fault on demand, which needs further work if
truncation is allowed.  You and Rohit are interested in enhancing
the generality of hugetlbfs.

I'd imagine supporting "read" and "write" would be the first priorities
if you were really trying to make hugetlbfs more like an ordinary fs.
But I thought it was intentionally kept at the minimum to do its job.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
