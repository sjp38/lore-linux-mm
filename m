Date: Fri, 15 Jun 2007 16:44:11 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: mm: Fix memory/cpu hotplug section mismatch and oops.
Message-Id: <20070615164411.ec1bdcc7.randy.dunlap@oracle.com>
In-Reply-To: <20070615030241.GA28493@linux-sh.org>
References: <20070614061316.GA22543@linux-sh.org>
	<20070614183015.9DD7.Y-GOTO@jp.fujitsu.com>
	<20070615030241.GA28493@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jun 2007 12:02:41 +0900 Paul Mundt wrote:

> On Thu, Jun 14, 2007 at 06:32:32PM +0900, Yasunori Goto wrote:
> > Thanks. I tested compile with cpu/memory hotplug off/on.
> > It was OK.
> > 
> > Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> > 
> It would be nice to have this for 2.6.22..

Yes, please.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
