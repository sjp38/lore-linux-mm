Message-ID: <20000926211016.A416@bug.ucw.cz>
Date: Tue, 26 Sep 2000 21:10:16 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: the new VM
References: <20000925163909.O22882@athlon.random> <Pine.LNX.4.21.0009251640330.9122-100000@elte.hu> <20000925170113.S22882@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000925170113.S22882@athlon.random>; from Andrea Arcangeli on Mon, Sep 25, 2000 at 05:01:13PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi!
> > i talked about GFP_KERNEL, not GFP_USER. Even in the case of GFP_USER i
> 
> My bad, you're right I was talking about GFP_USER indeed.
> 
> But even GFP_KERNEL allocations like the init of a module or any other thing
> that is static sized during production just checking the retval
> looks be ok.

Okay, I'm user on small machine and I'm doing stupid thing: I've got
6MB ram, and I keep inserting modules. I insert module_1mb.o. Then I
insert module_1mb.o. Repeat. How does it end? I think that
kmalloc(GFP_KERNEL) *has* to return NULL at some point. 

Killing apps is not a solution: If my insmoder is smaller than module
I'm trying to insert, and it happens to be the only process, you just
will not be able to kmalloc(GFP_KERNEL, sizeof(module)). Will you
panic at the end?

								Pavel
-- 
I'm pavel@ucw.cz. "In my country we have almost anarchy and I don't care."
Panos Katsaloulis describing me w.r.t. patents at discuss@linmodems.org
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
