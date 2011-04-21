Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CF5868D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:46:05 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LIHjZq001958
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:17:45 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LIjkDo1798376
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:45:46 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LIjd15027698
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:45:46 -0600
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104211328000.5741@router.home>
References: <1303337718.2587.51.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201530430.13948@chino.kir.corp.google.com>
	 <20110421221712.9184.A69D9226@jp.fujitsu.com>
	 <1303403847.4025.11.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104211328000.5741@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 21 Apr 2011 11:45:37 -0700
Message-ID: <1303411537.9048.3583.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>

On Thu, 2011-04-21 at 13:33 -0500, Christoph Lameter wrote:
> http://www.linux-mips.org/archives/linux-mips/2008-08/msg00154.html
> 
> http://mytechkorner.blogspot.com/2010/12/sparsemem.html
> 
> Dave Hansen, Mel: Can you provide us with some help? (Its Easter and so
> the europeans may be off for awhile) 

Yup, for sure.  It's also interesting how much code ppc64 removed when
they did this:

http://lists.ozlabs.org/pipermail/linuxppc64-dev/2005-November/006646.html

Please cc me on patches.  Or, if nobody else was planning on doing it, I
can take a stab at doing SPARSEMEM on one of the arches.  I won't be
able to _run_ it outside of qemu, but it might be quicker than someone
starting from scratch.

Was it really just m68k and parisc that need immediate attention?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
