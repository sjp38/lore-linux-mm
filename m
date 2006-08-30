From: Andi Kleen <ak@suse.de>
Subject: Re: libnuma interleaving oddness
Date: Wed, 30 Aug 2006 09:16:30 +0200
References: <20060829231545.GY5195@us.ibm.com> <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608300916.30210.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wednesday 30 August 2006 01:57, Christoph Lameter wrote:
> On Tue, 29 Aug 2006, Nishanth Aravamudan wrote:
> 
> > I don't know if this is a libnuma bug (I extracted out the code from
> > libnuma, it looked sane; and even reimplemented it in libhugetlbfs for
> > testing purposes, but got the same results) or a NUMA kernel bug (mbind
> > is some hairy code...) or a ppc64 bug or maybe not a bug at all.
> > Regardless, I'm getting somewhat inconsistent behavior. I can provide
> > more debugging output, or whatever is requested, but I wasn't sure what
> > to include. I'm hoping someone has heard of or seen something similar?
> 
> Are you setting the tasks allocation policy before the allocation or do 
> you set a vma based policy? The vma based policies will only work for 
> anonymous pages.

They should work for hugetlb/shmfs too. At least when I originally
wrote it. But the original patch I did for hugetlbfs for that was
never merged and I admit I have never rechecked if it worked with 
the patchkit that was merged later. The problem originally was
that hugetlbfs needed to be changed to do allocate-on-demand
instead of allocation-on-mmap, because mbind() comes after mmap()
and when mmap() already allocates it can't work.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
