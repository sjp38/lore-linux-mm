Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA17941
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 17:32:13 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14090.32072.214506.83641@dukat.scot.redhat.com>
Date: Tue, 6 Apr 1999 22:31:52 +0100 (BST)
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904061459330.437-100000@laser.random>
References: <37096E02.C9E53CE2@redhat.com>
	<Pine.LNX.4.05.9904061459330.437-100000@laser.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Doug Ledford <dledford@redhat.com>, Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 6 Apr 1999 15:04:36 +0200 (CEST), Andrea Arcangeli
<andrea@e-mind.com> said:

> I also think that I'll implement the cookie thing suggested by Mark since
> I am too much courious to see how much it will help (even if my mind is
> driven by RB-trees ;).

Trees are bad for this sort of thing in general: they can be as fast as
hashing for lookup, but are much slower for insert and delete
operations.  Insert and delete for the page cache _must_ be fast.
Expanding a hash table does not cost enough to offset the performance
problems.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
