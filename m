Received: from piglet.twiddle.net (davem@piglet.twiddle.net [207.104.6.26])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18939
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 18:53:45 -0400
Date: Tue, 6 Apr 1999 15:53:32 -0700
Message-Id: <199904062253.PAA12352@piglet.twiddle.net>
From: David Miller <davem@twiddle.net>
In-reply-to: <Pine.LNX.3.96.990407004419.11327A-100000@chiara.csoma.elte.hu>
	(message from Ingo Molnar on Wed, 7 Apr 1999 00:49:18 +0200 (CEST))
Subject: Re: [patch] arca-vm-2.2.5
References: <Pine.LNX.3.96.990407004419.11327A-100000@chiara.csoma.elte.hu>
Reply-To: davem@redhat.com
Sender: owner-linux-mm@kvack.org
To: mingo@chiara.csoma.elte.hu
Cc: sct@redhat.com, andrea@e-mind.com, cel@monkey.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   It should be 'inode >> 8' (which is done by the log2
   solution). Unless i'm misunderstanding something.

Consider that:

(((unsigned long) inode) >> (sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))

sort of approximates this and avoids the funny looking log2 macro. :-)

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
