Received: from piglet.twiddle.net (davem@piglet.twiddle.net [207.104.6.26])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18736
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 18:40:28 -0400
Date: Tue, 6 Apr 1999 15:40:08 -0700
Message-Id: <199904062240.PAA12189@piglet.twiddle.net>
From: David Miller <davem@twiddle.net>
In-reply-to: <Pine.LNX.3.96.990406234420.22306A-100000@chiara.csoma.elte.hu>
	(message from Ingo Molnar on Wed, 7 Apr 1999 00:19:36 +0200 (CEST))
Subject: Re: [patch] arca-vm-2.2.5
References: <Pine.LNX.3.96.990406234420.22306A-100000@chiara.csoma.elte.hu>
Sender: owner-linux-mm@kvack.org
To: mingo@chiara.csoma.elte.hu
Cc: sct@redhat.com, andrea@e-mind.com, cel@monkey.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   On Tue, 6 Apr 1999, Stephen C. Tweedie wrote:

   -#define i (((unsigned long) inode)/(sizeof(struct inode) \
		    & ~ (sizeof(struct inode) - 1)))
   +#define i (((unsigned long) inode-PAGE_OFFSET)/(sizeof(struct inode) \
		    & ~ (sizeof(struct inode) - 1)))

 ...

   btw. shouldnt it rather be something like: 

   #define log2(x) \

Look at the code just the 'i' in question will output :-)

     mov    inode, %o0
     srlx   %o0, 3, %o4

So on sparc64 atleast, it amounts to "inode >> 3".  So:

(sizeof(struct inode) & ~ (sizeof(struct inode) - 1))

is 8 on sparc64.  The 'i' construct is just meant to get rid of the
"non significant" lower bits of the inode pointer and it does so very
nicely. :-)

Later,
David S. Miller
davem@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
