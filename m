Date: Mon, 09 Jun 2008 09:38:58 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] add throttle to shrink_zone()
In-Reply-To: <20080608131203.e8cd69b7.akpm@linux-foundation.org>
References: <20080605021505.306358710@jp.fujitsu.com> <20080608131203.e8cd69b7.akpm@linux-foundation.org>
Message-Id: <20080609093741.7868.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > add throttle to shrink_zone() for performance improvement and prevent incorrect oom.
> 
> We should have a description of how all this works, please.  I thought
> that was present in earlier iterations of this patchset.
> 
> It's quite hard and quite unreliable to reverse engineer both the
> design and your thinking from the implementation.

Oh, sorry.
I'll write properly description soon.

Thans.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
