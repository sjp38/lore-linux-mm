Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4DC1D6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:58:56 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8E1ED82C365
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 16:05:39 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XULfcnrNOrYk for <linux-mm@kvack.org>;
	Thu,  5 Nov 2009 16:05:39 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 57EF182C36B
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 16:05:33 -0500 (EST)
Date: Thu, 5 Nov 2009 15:57:23 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC MM] Accessors for mm locking
In-Reply-To: <87vdho7kzn.fsf@basil.nowhere.org>
Message-ID: <alpine.DEB.1.10.0911051555320.7668@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1> <87vdho7kzn.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009, Andi Kleen wrote:

> My assumption was that a suitable scalable lock (or rather multi locks)
> would need to know about the virtual address, or at least the VMA.
> As in doing range locking for different address space areas.

Not sure why the address would matter. The main problem right now is that
there are cachelines in mm_struct that are bouncing for concurrent page faults
etc. Ranges wont help if you need to serialize access to mm_struct.

> So this simple abstraction doesn't seem to be enough to really experiment?

Look at the next patch which gives a rough implementation of using per cpu
counters for read locking instead of the rw semaphore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
