Date: Sun, 8 Jun 2008 13:12:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] add throttle to shrink_zone()
Message-Id: <20080608131203.e8cd69b7.akpm@linux-foundation.org>
In-Reply-To: <20080605021505.306358710@jp.fujitsu.com>
References: <20080605021211.871673550@jp.fujitsu.com>
	<20080605021505.306358710@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 05 Jun 2008 11:12:15 +0900 kosaki.motohiro@jp.fujitsu.com wrote:

> add throttle to shrink_zone() for performance improvement and prevent incorrect oom.

We should have a description of how all this works, please.  I thought
that was present in earlier iterations of this patchset.

It's quite hard and quite unreliable to reverse engineer both the
design and your thinking from the implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
