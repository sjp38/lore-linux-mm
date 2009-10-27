Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ABF636B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:25:39 -0400 (EDT)
Date: Tue, 27 Oct 2009 13:25:33 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091027202533.GB2726@sequoia.sous-sol.org>
References: <20091026185130.GC4868@random.random> <alpine.DEB.1.10.0910271630540.20363@V090114053VZO-1> <20091027182109.GA5753@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091027182109.GA5753@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Andrea Arcangeli (aarcange@redhat.com) wrote:
> On Tue, Oct 27, 2009 at 04:42:39PM -0400, Christoph Lameter wrote:
> > > 1) hugepages have to be swappable or the guest physical memory remains
> > >    locked in RAM and can't be paged out to swap
> > 
> > Thats not such a big issue IMHO. Paging is not necessary. Swapping is
> > deadly to many performance based loads. You would abort a job anyways that
> 
> Yes, swapping is deadly to performance based loads and it should be
> avoided as much as possible, but it's not nice when in order to get a
> boost in guest performance when the host isn't low on memory, you lose
> the ability to swap when the host is low on memory and all VM are
> locked in memory like in inferior-design virtual machines that won't
> ever support paging. When system starts swapping the manager can
> migrate the VM to other hosts with more memory free to restore the
> full RAM performance as soon as possible. Overcommit can be very
> useful at maxing out RAM utilization, just like it happens for regular
> linux tasks (few people runs with overcommit = 2 for this very
> reason.. besides overcommit = 2 includes swap in its equation so you
> can still max out ram by adding more free swap).

It's also needed if something like glibc were to take advantage of it in
a generic manner.

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
