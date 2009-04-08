Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 615945F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 02:13:13 -0400 (EDT)
Date: Wed, 8 Apr 2009 08:15:39 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/16] POISON: Intro
Message-ID: <20090408061539.GD17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407221542.91cd3c42.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090407221542.91cd3c42.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 10:15:42PM -0700, Andrew Morton wrote:
> On Tue,  7 Apr 2009 17:09:56 +0200 (CEST) Andi Kleen <andi@firstfloor.org> wrote:
> 
> > Upcoming Intel CPUs have support for recovering from some memory errors. This
> > requires the OS to declare a page "poisoned", kill the processes associated
> > with it and avoid using it in the future. This patchkit implements
> > the necessary infrastructure in the VM.
> 
> If the page is clean then we can just toss it and grab a new one from
> backing store without killing anyone.
> 
> Does the patchset do that?

Yes. But it only really works for shared mmap, anonymous and private
tends to be near always dirty.

Also you can disable even the early kill and only request kill
on access.

It also does some other tricks, like for dirty file just trigger
an IO error (although I must admit the dirty handling is rather
tricky and I would appreciate very careful review of that part)s

A few other known recovery tricks are not implemented yet
(like handling free memory[1]), but will be over time.

-Andi

[1] I didn't consider that one high priority since production
systems with long uptime shouldn't have much free memory.

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
