Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA31970
	for <linux-mm@kvack.org>; Wed, 2 Dec 1998 11:22:36 -0500
Date: Wed, 2 Dec 1998 16:21:01 GMT
Message-Id: <199812021621.QAA04235@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Update shared mappings
In-Reply-To: <Pine.LNX.3.96.981201182728.16745C-100000@dragon.bogus>
References: <199812011503.PAA18144@dax.scot.redhat.com>
	<Pine.LNX.3.96.981201182728.16745C-100000@dragon.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko.Calusic@CARNet.hr, Linux-MM List <linux-mm@kvack.org>, Andi Kleen <andi@zero.aec.at>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 1 Dec 1998 18:48:44 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> No deadlock at all. Are you sure you are using my _latest_ patch in
> arca-39? Some weeks ago I fixed this:

> 				if (shared->vm_mm == this->vm_mm)
> 					    ^^^^^          ^^^^^

Ah right, I was working from the version Zlatko posted here a week or so
ago.  This fix will indeed prevent the instant deadlock.

However, it is still susceptible to deadlock, because in msync() you
now hold the current mm semaphore while trying to take out somebody
else's mm semaphore.  If you have two processes doing that to each other
(ie. two processes mapping the same file r/w and doing msyncs), then you
can most certainly still deadlock.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
