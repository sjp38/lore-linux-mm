Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re:
	Remove page flags for software suspend)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200703041450.02178.rjw@sisk.pl>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
	 <45E6EEC5.4060902@yahoo.com.au> <200703011633.54625.rjw@sisk.pl>
	 <200703041450.02178.rjw@sisk.pl>
Content-Type: text/plain
Date: Thu, 08 Mar 2007 16:53:45 +0100
Message-Id: <1173369225.9438.32.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Johannes Berg <johannes@sipsolutions.net>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-03-04 at 14:50 +0100, Rafael J. Wysocki wrote:

> Okay, the next three messages contain patches that should do the trick.
> 
> They have been tested on x86_64, but not very thoroughly.

They look good to me, but what do I know about swsusp :-) 
I'll stick them in my laptop's kernel (boring i386-UP) and see what
happens.

I did notice you don't stick KERN_ prio markers in your printk()s not
sure what to think of that (or if its common practise and I'm just not
aware of it).

Thanks for doing this.

Peter



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
