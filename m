Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA00514
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 17:56:39 -0500
Date: Mon, 7 Dec 1998 22:56:26 GMT
Message-Id: <199812072256.WAA04256@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: readahead/behind algorithm
In-Reply-To: <Pine.LNX.3.96.981207195746.32057A-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.981207195746.32057A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 7 Dec 1998 21:17:56 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> Hi,
> I've thought a bit about what the 'ideal' readahead/behind
> algorithm would be and reached the following conclusion.

> 1. we test the presence of pages in the proximity of the
>    faulting page (31 behind, 32 ahead) building a map of
>    64 pages.

It will only be useful to start getting complex here if we take more
care about maintaining the logical contiguity of pages when we swap
them.  If swap gets fragmented, then doing this sort of readahead will
just use up bandwidth without giving any measurable performance gains.
It would be better thinking along those lines right now, I suspect.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
