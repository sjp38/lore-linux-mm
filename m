Date: Wed, 6 Dec 2006 23:03:38 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7645] New: Kernel BUG at mm/memory.c:1124
Message-Id: <20061206230338.b0bf2b9e.akpm@osdl.org>
In-Reply-To: <4577A36B.6090803@cern.ch>
References: <200612070355.kB73tGf4021820@fire-2.osdl.org>
	<20061206201246.be7fb860.akpm@osdl.org>
	<4577A36B.6090803@cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ramiro Voicu <Ramiro.Voicu@cern.ch>
Cc: linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 07 Dec 2006 06:15:23 +0100
Ramiro Voicu <Ramiro.Voicu@cern.ch> wrote:

>  Here is the stack trace after I've applied the patch
> 
> 
> Dec  7 06:12:11 xxxx kernel: [  319.720340] pte_val: 629025

hm.  A valid, read-only, accessed user page with a sane-looking pfn.
And this is repeatable, on two different machines.

I don't know what to do, sorry.  A bisection-search would have a good
chance of finding the bug, but that would be pretty painful.  It looks like
you were able to hit the bug after five minutes uptime, which helps.  Is it
always that easy to hit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
