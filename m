Date: Tue, 3 Jun 2008 22:57:52 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
Message-ID: <20080603205752.GK20824@one.firstfloor.org>
References: <20080603095956.781009952@amd.local0.net> <20080603100939.967775671@amd.local0.net> <1212515282.8505.19.camel@nimitz.home.sr71.net> <20080603182413.GJ20824@one.firstfloor.org> <1212519555.8505.33.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1212519555.8505.33.camel@nimitz.home.sr71.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

> The downside of something like this is that you have yet another data
> structure to manage.  Andi, do you think something like this would be
> workable?

The reason I don't like your proposal is that it makes only sense
with a lot of hugepage sizes being active at the same time. But the
API (one mount per size) doesn't really scale to that anyways.
It should support two (as on x86), three if you stretch it, but
anything beyond would be difficult.
If you really wanted to support a zillion sizes you would at least
first need a different flexible interface that completely hides page
sizes.
Otherwise you would drive both sysadmins and programmers crazy and 
overlong command lines would be the smallest of their problems
With two or even three sizes only the whole thing is not needed and my original
scheme works fine IMHO.

That is why I was also sceptical of the newly proposed sysfs interfaces. 
For two or three numbers you don't need a sysfs interface.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
