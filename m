Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA03902
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 07:03:15 -0400
Date: Thu, 23 Jul 1998 11:59:56 +0100
Message-Id: <199807231059.LAA00991@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <Pine.LNX.3.96.980722195943.13554A-100000@mirkwood.dummy.home>
References: <199807221036.LAA00829@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980722195943.13554A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, Zlatko.Calusic@CARNet.hr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 22 Jul 1998 20:01:51 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Wed, 22 Jul 1998, Stephen C. Tweedie wrote:
>> successfully with 8k NFS.  However, the zoned allocation can use memory
>> less efficiently: the odd free pages in the paged zone cannot be used by
>> non-paged users and vice versa, so overall performance may suffer.
>> Right now I'm cleaning the code up for a release against 2.1.110 so
>> that we can start testing.

> Hmm, I'm curious as to what categories your allocator
> divides memory users in. Is it just plain swappable
> vs. non-swappable

Yes, and so far it seems to work pretty well.

> or is it fragmentation-causing vs.  fragmentation sensitive or
> something entirely different?

As long as there are enough higher-order free pages to go around, the
fragmentation distinction is not so important.  The problem of course is
that the more different zone types we have, the less efficiently we can
use memory, so I really just want a minimal solution which does
something about fragmentation for non-swappable allocations.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
