Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA31720
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 13:01:55 -0500
Date: Mon, 7 Dec 1998 18:01:31 GMT
Message-Id: <199812071801.SAA06360@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <Pine.LNX.3.96.981207140223.23360K-100000@mirkwood.dummy.home>
References: <98Dec7.104648gmt.66310@gateway.ukaea.org.uk>
	<Pine.LNX.3.96.981207140223.23360K-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Neil Conway <nconway.list@ukaea.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 7 Dec 1998 14:04:04 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> what we really need is somebody to try it out on 4M and
> 8M machines...

Been doing that.  2.1.130 is the fastest kernel ever in 8MB (using
defrag builds over NFS as a benchmark): 25% faster that 2.0.36.  2.1.131
is consistently about 10% slower at the same job than 130 (but still
faster than 2.0 ever was).

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
