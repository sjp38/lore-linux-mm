Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 355DC8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:19:23 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1303411537.9048.3583.camel@nimitz>
References: <1303337718.2587.51.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201530430.13948@chino.kir.corp.google.com>
	 <20110421221712.9184.A69D9226@jp.fujitsu.com>
	 <1303403847.4025.11.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104211328000.5741@router.home>
	 <1303411537.9048.3583.camel@nimitz>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Apr 2011 13:19:16 -0500
Message-ID: <1303496357.2590.38.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>

On Thu, 2011-04-21 at 11:45 -0700, Dave Hansen wrote:
> On Thu, 2011-04-21 at 13:33 -0500, Christoph Lameter wrote:
> > http://www.linux-mips.org/archives/linux-mips/2008-08/msg00154.html
> > 
> > http://mytechkorner.blogspot.com/2010/12/sparsemem.html
> > 
> > Dave Hansen, Mel: Can you provide us with some help? (Its Easter and so
> > the europeans may be off for awhile) 
> 
> Yup, for sure.  It's also interesting how much code ppc64 removed when
> they did this:
> 
> http://lists.ozlabs.org/pipermail/linuxppc64-dev/2005-November/006646.html

I looked at converting parisc to sparsemem and there's one problem that
none of these cover.  How do you set up bootmem?  If I look at the
examples, they all seem to have enough memory in the first range to
allocate from, so there's no problem.  On parisc, with discontigmem, we
set up all of our ranges as bootmem (we can do this because we
effectively have one node per range).  Obviously, since sparsemem has a
single bitmap for all of the bootmem, we can no longer allocate all of
our memory to it (well, without exploding because some of our gaps are
gigabytes big).  How does everyone cope with this (do you search for
your largest range and use that as bootmem or something)?

James


If 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
