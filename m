Date: Wed, 27 Sep 2000 06:11:41 -0600
From: yodaiken@fsmlabs.com
Subject: Re: the new VM
Message-ID: <20000927061141.A26711@hq.fsmlabs.com>
References: <20000926211016.A416@bug.ucw.cz> <Pine.LNX.4.21.0009270935380.993-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0009270935380.993-100000@elte.hu>; from Ingo Molnar on Wed, Sep 27, 2000 at 09:42:45AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Pavel Machek <pavel@suse.cz>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 27, 2000 at 09:42:45AM +0200, Ingo Molnar wrote:
> 
> On Tue, 26 Sep 2000, Pavel Machek wrote:
> of the VM allocation issues. Returning NULL in kmalloc() is just a way to
> say: 'oops, we screwed up somewhere'. And i'd suggest to not work around

That is not at all how it is currently used in the kernel. 

> such screwups by checking for NULL and trying to handle it. I suggest to
> rather fix those screwups.

Kmalloc returns null when there is not enough memory to satisfy the request. What's
wrong with that?


-- 
---------------------------------------------------------
Victor Yodaiken 
Finite State Machine Labs: The RTLinux Company.
 www.fsmlabs.com  www.rtlinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
