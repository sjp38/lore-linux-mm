Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA10920
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 06:34:38 -0500
Date: Fri, 4 Dec 1998 11:34:18 GMT
Message-Id: <199812041134.LAA01682@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <Pine.LNX.3.96.981203184928.2886A-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.981203184928.2886A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 3 Dec 1998 18:56:34 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> The swapin enhancement consists of a simple swapin readahead.

One odd thing about the readahead: you don't start the readahead until
_after_ you have synchronously read in the first swap page of the
cluster.  Surely it is better to do the readahead first, so that you
are submitting one IO to disk, not two?

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
