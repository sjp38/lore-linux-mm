Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA01311
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 18:22:18 -0500
Date: Fri, 27 Nov 1998 10:31:04 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
In-Reply-To: <199811271602.QAA00642@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981127103023.21897G-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Benjamin Redelings I <bredelin@ucsd.edu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Fri, 27 Nov 1998, Stephen C. Tweedie wrote:
> 
> The patch below both makes sense from this perspective and seems to
> work, which is always a good sign!  Moreover, it is inherently
> self-tuning.  The more recently-accessed cache pages we encounter, the
> faster we will age the cache.

Looks sane to me. The previous counters never had any good reason behind
them either, this at least tries to reason about it. Applied.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
