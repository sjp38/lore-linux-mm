Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA17513
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 17:11:38 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14090.30842.367364.230774@dukat.scot.redhat.com>
Date: Tue, 6 Apr 1999 22:11:22 +0100 (BST)
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.BSF.4.03.9904061644370.3406-100000@funky.monkey.org>
References: <Pine.LNX.4.05.9904061831340.394-100000@laser.random>
	<Pine.BSF.4.03.9904061644370.3406-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: Andrea Arcangeli <andrea@e-mind.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 6 Apr 1999 16:47:23 -0400 (EDT), Chuck Lever <cel@monkey.org>
said:

>> but I was just assuming that the offset is always page-aligned.
>> I could write a simulation to check the hash function...

> i didn't realize that the "offset" argument would always be page-aligned.
> but still, why does it help to add the unshifted "offset"?  doesn't seem
> like there's any new information in that.

It is always aligned for the page cache (hence mixing in the lower bits
to the hash function shouldn't change anything), but the swap cache uses
the lower bits extensively, concentrating the swap cache into just a few
hash buckets unless we make this change.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
