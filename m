Message-ID: <45D4A38D.2070004@garzik.org>
Date: Thu, 15 Feb 2007 13:16:45 -0500
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [patch] build error: allnoconfig fails on mincore/swapper_space
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com> <20070212150802.f240e94f.akpm@linux-foundation.org> <45D12715.4070408@yahoo.com.au> <20070213121217.0f4e9f3a.randy.dunlap@oracle.com> <Pine.LNX.4.64.0702132224280.3729@blonde.wat.veritas.com> <20070213144909.70943de2.randy.dunlap@oracle.com> <Pine.LNX.4.64.0702140009320.21315@blonde.wat.veritas.com> <20070215085500.30e57866.randy.dunlap@oracle.com> <Pine.LNX.4.64.0702150957110.20368@woody.linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702150957110.20368@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, tony.luck@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> On Thu, 15 Feb 2007, Randy Dunlap wrote:
>> so, are we going to get a revert of 42da9cbd3eedde33a42acc2cb06f454814cf5de0 ?
>> Has that been requested?  or are there other plans?
> 
> It should be fixed now (I had patches from Nick, but got sidetracked by 
> trying to fix metacity for the gnome people). 

Wow, good luck with that.  metacity has, among other things, been making 
my web browser (firefox) and my lone game (nethack) behave strangely 
when it comes to opening new windows.

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
