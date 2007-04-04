Date: Wed, 4 Apr 2007 13:50:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] no ZERO_PAGE?
Message-Id: <20070404135030.0683fb49.akpm@linux-foundation.org>
In-Reply-To: <20070404.131111.62667528.davem@davemloft.net>
References: <20070330024048.GG19407@wotan.suse.de>
	<20070404033726.GE18507@wotan.suse.de>
	<Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
	<20070404.131111.62667528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, npiggin@suse.de, hugh@veritas.com, linux-mm@kvack.org, tee@sgi.com, holt@sgi.com, andrea@suse.de, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 04 Apr 2007 13:11:11 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> As I understand the patch being considered to remove ZERO_PAGE(), this
> kind of core dump will cause a lot of pages to be allocated, probably
> eating up a lot of system time as well as memory.

Point.

Also, what effect will the proposed changes have upon rss reporting,
and upon the numbers in /proc/pid/[s]maps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
