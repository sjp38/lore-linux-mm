Subject: Re: memory hotplug and mem=
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041007155854.GC14614@logos.cnet>
References: <20041001182221.GA3191@logos.cnet>
	 <4160F483.3000309@jp.fujitsu.com>  <20041007155854.GC14614@logos.cnet>
Content-Type: text/plain
Message-Id: <1097172146.22025.29.camel@localhost>
Mime-Version: 1.0
Date: Thu, 07 Oct 2004 11:36:19 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-10-07 at 08:58, Marcelo Tosatti wrote:
> Hi memory hotplug fellows,
> 
> Just in case you dont know, trying to pass "mem=" 
> causes the -test2 tree to oops on boot.
> 
> Any ideas of what is going on wrong?

Nope.  That's my normal mode of operation.  What kind of system?  How
much RAM?  

I've only tried it where the machine has 4G of ram, and I restrict it
down to 2.  I can imagine some funny stuff happening if the mem= causes
it to cross the highmem boundary.

> Haven't captured the oops, but can 
> if needed.

Let me do a bit of testing after I find out what your configuration is. 
I'm hopeful I can reproduce it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
