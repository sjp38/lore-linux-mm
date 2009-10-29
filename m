Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 989556B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:52:32 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 83A6E82C7D9
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:58:31 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id T48RNKt5ewJe for <linux-mm@kvack.org>;
	Thu, 29 Oct 2009 10:58:26 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 37E4482C77F
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:58:24 -0400 (EDT)
Date: Thu, 29 Oct 2009 14:51:11 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: RFC: Transparent Hugepage support
In-Reply-To: <20091027202533.GB2726@sequoia.sous-sol.org>
Message-ID: <alpine.DEB.1.10.0910291450580.18197@V090114053VZO-1>
References: <20091026185130.GC4868@random.random> <alpine.DEB.1.10.0910271630540.20363@V090114053VZO-1> <20091027182109.GA5753@random.random> <20091027202533.GB2726@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009, Chris Wright wrote:

> > Yes, swapping is deadly to performance based loads and it should be
> > avoided as much as possible, but it's not nice when in order to get a
> > boost in guest performance when the host isn't low on memory, you lose
> > the ability to swap when the host is low on memory and all VM are
> > locked in memory like in inferior-design virtual machines that won't
> > ever support paging. When system starts swapping the manager can
> > migrate the VM to other hosts with more memory free to restore the
> > full RAM performance as soon as possible. Overcommit can be very
> > useful at maxing out RAM utilization, just like it happens for regular
> > linux tasks (few people runs with overcommit = 2 for this very
> > reason.. besides overcommit = 2 includes swap in its equation so you
> > can still max out ram by adding more free swap).
>
> It's also needed if something like glibc were to take advantage of it in
> a generic manner.

How would glibc do that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
