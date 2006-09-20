Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20060919222656.52fadf3c.akpm@osdl.org>
References: <1158274508.14473.88.camel@localhost.localdomain>
	 <20060915001151.75f9a71b.akpm@osdl.org> <45107ECE.5040603@google.com>
	 <1158709835.6002.203.camel@localhost.localdomain>
	 <1158710712.6002.216.camel@localhost.localdomain>
	 <20060919172105.bad4a89e.akpm@osdl.org>
	 <1158717429.6002.231.camel@localhost.localdomain>
	 <20060919200533.2874ce36.akpm@osdl.org>
	 <1158728665.6002.262.camel@localhost.localdomain>
	 <20060919222656.52fadf3c.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 20 Sep 2006 16:54:59 +1000
Message-Id: <1158735299.6002.273.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mike Waychison <mikew@google.com>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

> It's a choice between two behaviours:
> 
> a) get stuck in the kernel until someone kills you and
> 
> b) fault the page in and proceed as expected.
> 
> Option b) is better, no?

That's what I don't understand... where is the actual race that can
cause the livelock you are mentioning. Is this that TryLock always
fails, we wait, the lock gets available but since we have dropped the
semaphore around the wait, it might get stolen again by the time we are
taking the mmap_sem back and that going on ever and ever again while
lock_page() would get precedence since we have the mmap_sem ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
