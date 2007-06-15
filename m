Date: Fri, 15 Jun 2007 12:02:41 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: mm: Fix memory/cpu hotplug section mismatch and oops.
Message-ID: <20070615030241.GA28493@linux-sh.org>
References: <20070614061316.GA22543@linux-sh.org> <20070614183015.9DD7.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070614183015.9DD7.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 14, 2007 at 06:32:32PM +0900, Yasunori Goto wrote:
> Thanks. I tested compile with cpu/memory hotplug off/on.
> It was OK.
> 
> Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
It would be nice to have this for 2.6.22..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
