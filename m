Received: from mail.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA25993
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 01:43:25 -0500
Subject: Re: Why don't shared anonymous mappings work?
References: <199901061523.IAA14788@nyx10.nyx.net> <m1d84sgoyj.fsf@flinx.ccr.net>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 06 Jan 1999 23:55:03 -0600
In-Reply-To: ebiederm+eric@ccr.net's message of "06 Jan 1999 13:51:00 -0600"
Message-ID: <m1ww2zeifc.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Colin Plumb <colin@nyx.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

And of course the last reason I just thought of, which is probably the real reason.

Currenlty anonymous pages if the are writable are assumed to have exactly
one mapping, or if it is in the swap cache the page is assumed to be read only.

So reusing the swap inode could be a real problem.

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
