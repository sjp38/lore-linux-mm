Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9718C6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 18:23:01 -0400 (EDT)
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Alok Kataria <akataria@vmware.com>
Reply-To: akataria@vmware.com
In-Reply-To: <1245795352.17685.31312.camel@nimitz>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
	 <1245736441.18339.21.camel@alok-dev1>  <4A41481D.1060607@redhat.com>
	 <1245793331.24110.33.camel@alok-dev1> <1245795352.17685.31312.camel@nimitz>
Content-Type: text/plain
Date: Tue, 23 Jun 2009 15:23:43 -0700
Message-Id: <1245795823.24110.48.camel@alok-dev1>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Tue, 2009-06-23 at 15:15 -0700, Dave Hansen wrote:
> On Tue, 2009-06-23 at 14:42 -0700, Alok Kataria wrote:
> > One thing that i forgot to mention earlier is that, I just need a way to
> > provide a hint about the total locked memory  on the system and it
> > doesn't need to be the exact number at that point in time.
> > 
> > Lee, due to this reason lazy culling of unevictable pages is fine too. 
> > 
> > Hugepages, similar to mlocked pages, are special because the user could
> > specify how much memory it wants to reserve for this purpose. So that
> > needs to be taken into consideration i.e it cannot be calculated in some
> > way. 
> 
> Could you just teach the thing to which you are hinting that it also
> needs to go look in sysfs for huge page counts?

:) yeah i could do that too...the point is that its a module and the
function to get the hugepages count is not exported right now. I could
very well add this as an exported symbol and use it from there, but
there can be someone who doesn't want symbols to be unnecessarily
exported if their is no in-tree modular usage of that symbol. 

Other than that it also doesn't quite sound right that I have to query
the kernel for different variables when unevictable should get me all of
user specified locked usage.

Thanks,
Alok

>   Or, is there a
> requirement that it come out of a single meminfo field?
> 
> -- Dave
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
