Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06647
	for <linux-mm@kvack.org>; Sun, 30 May 1999 13:49:51 -0400
Date: Sun, 30 May 1999 10:49:32 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] [PATCH] vm_store
In-Reply-To: <m14sku4gcc.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.95.990530104819.18638K-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-kernel@vger.rutgers.edu, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 30 May 1999, Eric W. Biederman wrote:
>
> This patch creates the the abstraction of a vm_store, allowing the
> page cache to be seperated from the vfs layer.

I don't think vm_store is very interesting, unless it can be made to
contain the current "vm_ops" structure. At the very least you should move
vm_ops into vm_store, I feel - before that is done I don't see any reason
for vm_store existing at all..

I _assume_ that was the plan all along?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
