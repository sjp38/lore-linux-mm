Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 70AC26B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:14:55 -0500 (EST)
Date: Fri, 6 Nov 2009 20:14:48 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC MM] mmap_sem scaling: only scan cpus used by an mm
Message-ID: <20091106191448.GD819@basil.fritz.box>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1> <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1> <87r5sc7kst.fsf@basil.nowhere.org> <alpine.DEB.1.10.0911051558220.7668@V090114053VZO-1> <20091106073946.GV31511@one.firstfloor.org> <alpine.DEB.1.10.0911061352320.22205@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0911061352320.22205@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 06, 2009 at 01:53:35PM -0500, Christoph Lameter wrote:
> One way to reduce the cost of the writer lock is to track the cpus used
> and loop over the processors in that bitmap.

Can't you use the same mask as is used for TLB flushing?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
