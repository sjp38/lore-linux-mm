Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA15001
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 13:16:03 -0400
Date: Tue, 6 Apr 1999 19:16:12 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.BSF.4.03.9904061133580.8679-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.05.9904061831340.394-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Chuck Lever wrote:

>> We always, always use page-aligned lookups for the page cache.
>> (Actually there is one exception: certain obsolete a.out binaries, which
>> are demand paged with the pages beginning at offset 1K into the binary.
>> We don't support cache coherency for those and we don't support them at
>> all on filesystems with a >1k block size.  It doesn't impact on the hash
>> issue.)
>
>i guess i'm confused then.  what good does this change do:

Hmm I think I misunderstood you point, Chuck. I thought you was
complaining about the fact that some hash entry could be unused and other
overloaded but I was just assuming that the offset is always page-aligned.
I could write a simulation to check the hash function...

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
