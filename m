Date: Thu, 9 Aug 2007 10:04:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc2-mm1
Message-Id: <20070809100438.386010ac.akpm@linux-foundation.org>
In-Reply-To: <46BB3E92.5040007@googlemail.com>
References: <20070809015106.cd0bfc53.akpm@linux-foundation.org>
	<46BB3499.5090803@googlemail.com>
	<46BB3E92.5040007@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Michal Piotrowski <michal.k.k.piotrowski@googlemail.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 09 Aug 2007 18:19:30 +0200 Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> This might be related. The kernel is tainted because I hit
> kernel BUG at /home/devel/linux-mm/mm/swap_state.c:78!

umm, possibly.  If we went BUG while holding a spinlock then sure, 
a future lockup is pretty much inevitable.  But the lockdep
uninitialised-lock complaint is a bit of a surprise.

Can you please retest with Hugh's fix applied?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
