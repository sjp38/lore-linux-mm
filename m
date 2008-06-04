Date: Wed, 4 Jun 2008 03:10:16 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
Message-ID: <20080604011016.GC30863@wotan.suse.de>
References: <20080603095956.781009952@amd.local0.net> <20080603100939.967775671@amd.local0.net> <1212515282.8505.19.camel@nimitz.home.sr71.net> <20080603182413.GJ20824@one.firstfloor.org> <1212519555.8505.33.camel@nimitz.home.sr71.net> <20080603205752.GK20824@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080603205752.GK20824@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 03, 2008 at 10:57:52PM +0200, Andi Kleen wrote:
> > The downside of something like this is that you have yet another data
> > structure to manage.  Andi, do you think something like this would be
> > workable?
> 
> The reason I don't like your proposal is that it makes only sense
> with a lot of hugepage sizes being active at the same time. But the
> API (one mount per size) doesn't really scale to that anyways.
> It should support two (as on x86), three if you stretch it, but
> anything beyond would be difficult.
> If you really wanted to support a zillion sizes you would at least
> first need a different flexible interface that completely hides page
> sizes.
> Otherwise you would drive both sysadmins and programmers crazy and 
> overlong command lines would be the smallest of their problems
> With two or even three sizes only the whole thing is not needed and my original
> scheme works fine IMHO.
> 
> That is why I was also sceptical of the newly proposed sysfs interfaces. 
> For two or three numbers you don't need a sysfs interface.

I do think your proc enhancements are clever, and you're right that for
the current setup they are pretty workable. The reason I haven't submitted
them in this round is because they do cause libhugetlbfs failures...
maybe that's just because the regression suite does really dumb parsing,
and nothing important will break, but it is the only thing I have to go on
so I have to give it some credit ;)

With the sysfs API, we have a way to control the other hstates, so it
takes a little importance off the proc interface.

sysfs doesn't appear to give a huge improvement yet (although I still
think it is nicer), but I think the hugetlbfs guys want to have control
over which nodes things get allocated on etc. so I think proc really
was going to run out of steam at some point.

Anyway, my point is just that sysfs is the way forward, but I'm also not
against people tinkering with /proc if it isn't going to cause problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
