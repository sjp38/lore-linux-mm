Date: Thu, 7 Oct 2004 14:01:38 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: memory hotplug and mem=
Message-ID: <20041007170138.GC15186@logos.cnet>
References: <20041001182221.GA3191@logos.cnet> <4160F483.3000309@jp.fujitsu.com> <20041007155854.GC14614@logos.cnet> <1097172146.22025.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1097172146.22025.29.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2004 at 11:36:19AM -0700, Dave Hansen wrote:
> On Thu, 2004-10-07 at 08:58, Marcelo Tosatti wrote:
> > Hi memory hotplug fellows,
> > 
> > Just in case you dont know, trying to pass "mem=" 
> > causes the -test2 tree to oops on boot.
> > 
> > Any ideas of what is going on wrong?
> 
> Nope.  That's my normal mode of operation.  What kind of system?  How
> much RAM?  

standard P4 desktop system - 512M.

> I've only tried it where the machine has 4G of ram, and I restrict it
> down to 2.  I can imagine some funny stuff happening if the mem= causes
> it to cross the highmem boundary.

No highmem involved at all.

> > Haven't captured the oops, but can 
> > if needed.
> 
> Let me do a bit of testing after I find out what your configuration is. 
> I'm hopeful I can reproduce it.

mem=128M or mem=256M made it crash. Keep me posted.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
