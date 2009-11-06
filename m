Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE6236B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 12:44:46 -0500 (EST)
Date: Fri, 6 Nov 2009 18:44:39 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu
	counter instead
Message-ID: <20091106174439.GB819@basil.fritz.box>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1> <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1> <87r5sc7kst.fsf@basil.nowhere.org> <alpine.DEB.1.10.0911051558220.7668@V090114053VZO-1> <20091106073946.GV31511@one.firstfloor.org> <alpine.DEB.1.10.0911061208370.5187@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0911061208370.5187@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 06, 2009 at 12:08:54PM -0500, Christoph Lameter wrote:
> On Fri, 6 Nov 2009, Andi Kleen wrote:
> 
> > Yes but all the major calls still take mmap_sem, which is not ranged.
> 
> But exactly that issue is addressed by this patch!

Major calls = mmap, brk, etc.

Only for page faults, not for anything that takes it for write.

Anyways the better reader lock is a step in the right direction, but
I have my doubts it's a good idea to make write really slow here.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
