Date: Wed, 26 Nov 2008 00:16:50 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] memcg reclaim shouldn't change zone->recent_rotated
 statics.
Message-ID: <20081126001650.280530d0@lxorguk.ukuu.org.uk>
In-Reply-To: <20081126091027.3CA6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081125121842.26C5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081125155422.6ab07caf.akpm@linux-foundation.org>
	<20081126091027.3CA6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> however, "_p" isn't linux convention.
> so, I like "is_" or "can_" (or likes somethingelse) prefix :)

_p is from lisp but Ted did sneak tty_hung_up_p() into the kernel many
years ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
