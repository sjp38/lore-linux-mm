Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA13666
	for <linux-mm@kvack.org>; Tue, 14 Jul 1998 16:38:53 -0400
Date: Tue, 14 Jul 1998 18:32:45 +0100
Message-Id: <199807141732.SAA07242@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87lnpxy582.fsf@atlas.CARNet.hr>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<87lnpxy582.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 13 Jul 1998 20:29:33 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> I agree that ageing of the page cache has a bad impact on the
> performance.

> Just to mention, I have 64MB of physical memory, and my machine is
> definitely not memory starved, but it also suffers from some of the
> recent VM changes.

Yep.  Has anybody else got observations about what sort of
configurations are helped or hindered by the current 2.1 changes?

> That (removing cache limits) is one of my favorite changes.

> Free memory == unused memory == bad policy!

> There is no reason why any of the caches would not utilize all of the
> free memory at any given moment.

The existing limits don't affect the ability of the cache to grow; they
just give a target bound for the cache when we start trying to get pages
back for something else.

> If anybody want to see, I can provide benchmark results, but I'm not
> prepared to compile another kernel image if nobody's interested. :)

Well, I've been compiling kernels all day for this. :)  Any information
you can give will help, but for now it does look as if backing out the
cache ageing is a necessary first step.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
