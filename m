From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re: Remove page flags for software suspend)
Date: Thu, 8 Mar 2007 23:11:57 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200703041450.02178.rjw@sisk.pl> <1173369225.9438.32.camel@twins>
In-Reply-To: <1173369225.9438.32.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703082311.58605.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Johannes Berg <johannes@sipsolutions.net>
List-ID: <linux-mm.kvack.org>

On Thursday, 8 March 2007 16:53, Peter Zijlstra wrote:
> On Sun, 2007-03-04 at 14:50 +0100, Rafael J. Wysocki wrote:
> 
> > Okay, the next three messages contain patches that should do the trick.
> > 
> > They have been tested on x86_64, but not very thoroughly.
> 
> They look good to me, but what do I know about swsusp :-) 
> I'll stick them in my laptop's kernel (boring i386-UP) and see what
> happens.

Thanks!

> I did notice you don't stick KERN_ prio markers in your printk()s not
> sure what to think of that (or if its common practise and I'm just not
> aware of it).

This means use the default (which initially is KERN_WARNING, AFAICT).

> Thanks for doing this.

You're welcome. :-)

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
