Date: Tue, 20 May 2003 01:11:57 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [RFC][PATCH] vm_operation to avoid pagefault/inval race
Message-Id: <20030520011157.3f6b73a6.akpm@digeo.com>
In-Reply-To: <20030519182305.C1813@us.ibm.com>
References: <200305172021.56773.phillips@arcor.de>
	<20030517124948.6394ded6.akpm@digeo.com>
	<20030519182305.C1813@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: phillips@arcor.de, hch@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Paul E. McKenney" <paulmck@us.ibm.com> wrote:
>
> So the general idea is to do something as follows, right?

It sounds reasonable.  A matter of putting together the appropriate
library functions and refactoring a few things.

> 
> o	Make a function, perhaps named something like
> 	install_new_page(), that does the PTE-installation
> 	and RSS-adjustment tasks currently performed by
> 	both do_no_page() and by do_anonymous_page().

That's similar to mm/fremap.c:install_page().  (Which forgets to call
update_mmu_cache().  Debatably a buglet.)

However there is not a lot of commonality between the various nopage()s and
there may not be a lot to be gained from all this.  There is subtle code in
there and it is performance-critical.  I'd be inclined to try to minimise
overall code churn in this work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
