Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA13615
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 11:38:17 -0500
Date: Tue, 26 Jan 1999 16:37:04 GMT
Message-Id: <199901261637.QAA03838@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990126145544.11981B-100000@chiara.csoma.elte.hu>
References: <m1059TX-0007U1C@the-village.bc.nu>
	<Pine.LNX.3.96.990126145544.11981B-100000@chiara.csoma.elte.hu>
Sender: owner-linux-mm@kvack.org
To: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 26 Jan 1999 15:15:04 +0100 (CET), MOLNAR Ingo
<mingo@chiara.csoma.elte.hu> said:

> this is conceptually 'boot-time allocation of big buffers' by splitting
> all available memory into two pieces:

> 	size_kernel: generic memory
> 	size_user: only swappable

which is something we already need to do if we want to support 4G
physical memory cleanly (ie. add support for anonymous and cache pages
to be mapped on demand into the kernel's VA, rather than having the
whole of physical memory virtually mapped at all times).

> the toughest part is the 'moving' stuff, which is not yet present and
> hard/impossible to implement in a clean and maintainable way. 

Not at all.  We only need to be able to free swappable pages: only the
swappable region will be usable for large contiguous allocations.  We
don't even need to move them: they can be paged back in afterwards.
Obviously this is expensive if we expect to do it often, but in reality
it is probably something we only need to do at driver setup time (or
occasionally on driver open).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
