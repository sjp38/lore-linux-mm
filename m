Date: Thu, 3 May 2007 22:47:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] change global zonelist order v4 [0/2]
Message-Id: <20070503224730.3bc6f8a8.akpm@linux-foundation.org>
In-Reply-To: <20070427144530.ae42ee25.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070427144530.ae42ee25.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 27 Apr 2007 14:45:30 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Hi, this is version 4. including Lee Schermerhon's good rework.
> and automatic configuration at boot time.

hm, this adds rather a lot of code.  Have we established that it's worth
it?

And it's complex - how do poor users know what to do with this new control?


This:

+ *	= "[dD]efault | "0"	- default, automatic configuration.
+ *	= "[nN]ode"|"1" 	- order by node locality,
+ *         			  then zone within node.
+ *	= "[zZ]one"|"2" - order by zone, then by locality within zone

seems a bit excessive.  I think just the 0/1/2 plus documentation would
suffice?


I haven't followed this discussion very closely I'm afraid.  If we came up
with a good reason why Linux needs this feature then could someone please
(re)describe it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
