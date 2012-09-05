Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id DCC066B0083
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 06:21:00 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1T9CjD-0006Te-5d
	for linux-mm@kvack.org; Wed, 05 Sep 2012 10:20:59 +0000
Received: from dhcp-089-099-019-018.chello.nl ([89.99.19.18] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1T9CjC-0000wa-DR
	for linux-mm@kvack.org; Wed, 05 Sep 2012 10:20:58 +0000
Subject: Re: [RFC 0/5] forced comounts for cgroups.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <50471C0C.7050600@parallels.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
	 <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
	 <5047074D.1030104@parallels.com>
	 <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <50470A87.1040701@parallels.com>
	 <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <50470EBF.9070109@parallels.com>
	 <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <1346835993.2600.9.camel@twins>
	 <20120905091140.GH3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <50471782.6060800@parallels.com> <1346837209.2600.14.camel@twins>
	 <50471C0C.7050600@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Sep 2012 12:20:53 +0200
Message-ID: <1346840453.2461.6.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On Wed, 2012-09-05 at 13:31 +0400, Glauber Costa wrote:
> 
> You wouldn't have to do more than one hierarchy walks for that. What
> Tejun seems to want, is the ability to not have a particular controller
> at some point in the tree. But if they exist, they are always together. 

Right, but the accounting is very much tied to the control structures, I
suppose we could change that, but my jet-leg addled brain isn't seeing
anything particularly nice atm.

But I don't really see the point though, this kind of interface would
only ever work for the non-controlling and controlling controller
combination (confused yet ;-), and I don't think we have many of those.

I would really rather see a simplification of the entire cgroup
interface space as opposed to making it more complex. And adding this
subtree 'feature' only makes it more complex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
