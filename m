Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA11919
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 09:47:43 -0500
Date: Fri, 4 Dec 1998 14:47:17 GMT
Message-Id: <199812041447.OAA04549@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: SWAP: Linux far behind Solaris or I missed something (fwd)
In-Reply-To: <3667E533.ADFBFDBB@bull.net>
References: <Pine.LNX.3.96.981203130156.1008D-100000@mirkwood.dummy.home>
	<199812041205.MAA01773@dax.scot.redhat.com>
	<3667E533.ADFBFDBB@bull.net>
Sender: owner-linux-mm@kvack.org
To: Jean-Michel VANSTEENE <Jean-Michel.Vansteene@bull.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 04 Dec 1998 14:35:47 +0100, Jean-Michel VANSTEENE
<Jean-Michel.Vansteene@bull.net> said:

> Randomly from the whole block of memory. I know this is really a
> memory shake. But i would like to figure out if the swap heavily
> penalizes the performance. Or, in other words, the percentage of
> swap usage after which performances are too low....

Which kernel, and could you show a "vmstat 1" run for the duration of
one of these tests?

Thanks,
 Stephen.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
