Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages /
	all_unreclaimable braindamage
From: Thomas Gleixner <tglx@linutronix.de>
Reply-To: tglx@linutronix.de
In-Reply-To: <200411051532.51150.jbarnes@sgi.com>
References: <20041105200118.GA20321@logos.cnet>
	 <200411051532.51150.jbarnes@sgi.com>
Content-Type: text/plain
Date: Sat, 06 Nov 2004 00:47:36 +0100
Message-Id: <1099698456.2810.138.camel@thomas>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Barnes <jbarnes@sgi.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <piggin@cyberone.com.au>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2004-11-05 at 15:32 -0800, Jesse Barnes wrote:
> On Friday, November 05, 2004 12:01 pm, Marcelo Tosatti wrote:
> > Comments?
> 
> Sounds good, though we may want to do a couple of more things, we shouldn't 
> kill root tasks quite as easily and we should avoid zombies since they may be 
> large apps in the process of exiting, and killing them would be bad (iirc 
> it'll cause a panic).
> 

Yep, it makes sense, but it still does not fix the selection problem,
where e.g. sshd is killed while a out of control forking server floods
the machine with child processes. 

Patch to address this:
 http://marc.theaimsgroup.com/?l=linux-kernel&m=109922680000746&w=2

tglx






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
