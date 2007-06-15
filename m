Date: Fri, 15 Jun 2007 16:57:19 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: mm: Fix memory/cpu hotplug section mismatch and oops.
In-Reply-To: <20070615164411.ec1bdcc7.randy.dunlap@oracle.com>
Message-ID: <alpine.LFD.0.98.0706151656480.14121@woody.linux-foundation.org>
References: <20070614061316.GA22543@linux-sh.org> <20070614183015.9DD7.Y-GOTO@jp.fujitsu.com>
 <20070615030241.GA28493@linux-sh.org>
 <20070615164411.ec1bdcc7.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Fri, 15 Jun 2007, Randy Dunlap wrote:

> On Fri, 15 Jun 2007 12:02:41 +0900 Paul Mundt wrote:
> 
> > On Thu, Jun 14, 2007 at 06:32:32PM +0900, Yasunori Goto wrote:
> > > Thanks. I tested compile with cpu/memory hotplug off/on.
> > > It was OK.
> > > 
> > > Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> > > 
> > It would be nice to have this for 2.6.22..
> 
> Yes, please.

I pushed out my tree that should include this one about ten minutes ago..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
