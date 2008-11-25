Date: Tue, 25 Nov 2008 15:54:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg reclaim shouldn't change zone->recent_rotated
 statics.
Message-Id: <20081125155422.6ab07caf.akpm@linux-foundation.org>
In-Reply-To: <20081125121842.26C5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081125121842.26C5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Nov 2008 12:22:53 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> +	if (scan_global_lru(sc))

mutter.  scan_global_lru() is a terrible function name.  Anyone reading
that code would expect that this function, umm, scans the global LRU.

gcc has a nice convention wherein such functions have a name ending in
"_p" (for "predicate").  Don't do this :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
