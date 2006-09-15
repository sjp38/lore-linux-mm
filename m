Date: Thu, 14 Sep 2006 17:19:16 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
In-Reply-To: <1158274508.14473.88.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0609141718090.4388@g5.osdl.org>
References: <1158274508.14473.88.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Fri, 15 Sep 2006, Benjamin Herrenschmidt wrote:
> 
> This wait is interruptible. However, we have no way to fail "gracefully"
> from no_page() if the routine we use underneath returns a failure due to
> a signal (we use, logically, -EINTR). It's a generic issue with no_page
> handlers. They can either wait non-interruptibly, or fail with a sigbus
> or oom result.

I certainly personally have nothing against adding a NOPAGE_RETRY, it 
seems very straightforward. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
