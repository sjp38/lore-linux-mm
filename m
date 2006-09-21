Date: Thu, 21 Sep 2006 15:41:05 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
Message-Id: <20060921154105.904313f7.akpm@osdl.org>
In-Reply-To: <1158876304.26347.129.camel@localhost.localdomain>
References: <1158274508.14473.88.camel@localhost.localdomain>
	<20060915001151.75f9a71b.akpm@osdl.org>
	<45107ECE.5040603@google.com>
	<1158709835.6002.203.camel@localhost.localdomain>
	<1158710712.6002.216.camel@localhost.localdomain>
	<20060919172105.bad4a89e.akpm@osdl.org>
	<1158717429.6002.231.camel@localhost.localdomain>
	<20060919200533.2874ce36.akpm@osdl.org>
	<1158728665.6002.262.camel@localhost.localdomain>
	<20060919222656.52fadf3c.akpm@osdl.org>
	<1158735299.6002.273.camel@localhost.localdomain>
	<20060920105317.7c3eb5f4.akpm@osdl.org>
	<1158876304.26347.129.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Mike Waychison <mikew@google.com>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Sep 2006 08:05:04 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> > So I think there's a nasty DoS here if we permit infinite retries.  But
> > it's not just that - there might be other situations under really heavy
> > memory pressure where livelocks like this can occur.  It's just a general
> > robustness-of-implementation issue.
> 
> Got it. Now, changing args to no_page() will be a pretty big task....
> 

Not as big as removing the pt_regs arg from every interrupt handler ;)

But pretty mechanical.  Problem is, I don't think we have our mechanic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
