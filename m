Subject: Re: [PATCH] Add maintainer for memory management
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20060724001128.6d513d20.rdunlap@xenotime.net>
References: <1153713707.4002.43.camel@localhost.localdomain>
	 <20060724001128.6d513d20.rdunlap@xenotime.net>
Content-Type: text/plain
Date: Mon, 24 Jul 2006 07:56:33 -0400
Message-Id: <1153742193.4002.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-07-24 at 00:11 -0700, Randy.Dunlap wrote:

> Christoph L. is very NUMA & big-iron focused.  He also breaks
> things (at least builds if not working code) a bit too often IMO.

Like I said, the criteria was who responded the most. I actually don't
keep track of the mm work and someone else is probably better at
deciding this. But since it doesn't exist _at_all_ in MAINTAINERS I
figured that if I post this, it will soon be added.

> 
> Andrew, Nick, Peter Zijlstra, Pekka, Manfred, Hugh Dickins
> are all a better choice IMO.  However, if Andrew & Linus want
> to merge that one...

Even if Christoph is not chosen, please do add a MEMORY MANAGEMENT in
the MAINTAINERS.  I don't want to keep looking back in my email logs to
remember what that mm email list was called again.

Also, I would like to see linux-arch mentioned in the MAINTAINERS file
since before I new about it, I just emailed every arch maintainer that I
could find in the list separately, when making a change that all archs
needed.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
