From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14184.50648.347245.288706@dukat.scot.redhat.com>
Date: Thu, 17 Jun 1999 10:54:32 +0100 (BST)
Subject: Re: kmem_cache_init() question
In-Reply-To: <000001beb706$5a8b06a0$b7e0a8c0@prashanth.wipinfo.soft.net>
References: <000001beb706$5a8b06a0$b7e0a8c0@prashanth.wipinfo.soft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cprash@wipinfo.soft.net
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 15 Jun 1999 13:39:12 +0530, "Prashanth C."
<cprash@wipinfo.soft.net> said:

> I found that num_physpages is initialized in mem_init() function
> (arch/i386/mm/init.c).  But start_kernel() calls kmem_cache_init() before
> mem_init().  So, num_physpages will always(?) be zero when the above code
> segment is executed.

> Is num_physpages is initialized somewhere else before kmem_cache_init() is
> called by start_kernel()?  

The great thing about having all the source code is that if you can't
instantly find the answer to such a question just by searching code, it
takes no time at all to add a 

	printk ("num_physpages is now %lu\n", num_physpages);

to init.c to find out for yourself. :)

And if this turns out to be a real bug, do let us know...

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
