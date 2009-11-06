Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0F2776B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:47:24 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2C4B482C4AB
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:54:14 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AhyOA5vzTu6N for <linux-mm@kvack.org>;
	Fri,  6 Nov 2009 14:54:14 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0A2C582C4BB
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:54:08 -0500 (EST)
Date: Fri, 6 Nov 2009 14:45:58 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC MM] mmap_sem scaling: only scan cpus used by an mm
In-Reply-To: <20091106191448.GD819@basil.fritz.box>
Message-ID: <alpine.DEB.1.10.0911061443120.21579@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1> <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1> <87r5sc7kst.fsf@basil.nowhere.org> <alpine.DEB.1.10.0911051558220.7668@V090114053VZO-1> <20091106073946.GV31511@one.firstfloor.org>
 <alpine.DEB.1.10.0911061352320.22205@V090114053VZO-1> <20091106191448.GD819@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009, Andi Kleen wrote:

> On Fri, Nov 06, 2009 at 01:53:35PM -0500, Christoph Lameter wrote:
> > One way to reduce the cost of the writer lock is to track the cpus used
> > and loop over the processors in that bitmap.
>
> Can't you use the same mask as is used for TLB flushing?

They are clearing the cpus that are no longer in use. We could use the
same mask if we would transfer the counters but for that we would need to
make sure that no concurrent user of the counters is out there. Probably
too expensive to do.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
