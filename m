Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA04151
	for <linux-mm@kvack.org>; Tue, 8 Dec 1998 07:36:10 -0500
Date: Tue, 8 Dec 1998 12:35:56 GMT
Message-Id: <199812081235.MAA02355@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <Pine.LNX.3.96.981208032438.8407C-100000@mirkwood.dummy.home>
References: <366C8214.F58091FF@thrillseeker.net>
	<Pine.LNX.3.96.981208032438.8407C-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Billy Harvey <Billy.Harvey@thrillseeker.net>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 8 Dec 1998 03:31:25 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On a swapout, we will scan ahead of where we are (p->swap_address)
> and swap out the next number of pages too. 

Yes, but be aware that for good performance you need to combine this
with a mechanism to ensure swap space does not become fragmented, and
you also need a swap-behind mechanism for sequential accesses (so that
if an application is scanning a data set sequentially, the un-accessed
space behind the current application "cursor" is being removed from
memory just as fast as the stuff about to be accessed is being brought
in). 

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
