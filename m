From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re: Remove page flags for software suspend)
Date: Thu, 8 Mar 2007 23:54:45 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200703082333.06679.rjw@sisk.pl> <1173393815.3831.29.camel@johannes.berg>
In-Reply-To: <1173393815.3831.29.camel@johannes.berg>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703082354.46001.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thursday, 8 March 2007 23:43, Johannes Berg wrote:
> On Thu, 2007-03-08 at 23:33 +0100, Rafael J. Wysocki wrote:
> 
> > > Unfortunately I won't be able to actually try this on hardware until the
> > > 20th or so.
> > 
> > OK, it's not an urgent thing. ;-)
> 
> True :)
> 
> > Well, I don't think so.  If I understand the definition of system_state
> > correctly, it is initially equal to SYSTEM_BOOTING.  Then, it's changed to
> > SYSTEM_RUNNING in init/main.c after the bootmem has been freed.
> 
> No, I think you're confusing bootmem with initmem right now.

Yes, you're right, sorry.

> If you actually look at the code then free_all_bootmem is called as part of
> mem_init() on powerpc, which is called from start_kernel() a long time
> before initcalls are done and system state is set.
> 
> Put it this way. By the time initcalls are done, I can no longer use
> bootmem. I tested this and it panics. But if you look at the code in
> init/main.c, system_state is only changed after initcalls are done.

That's true.

In that case your patch seems to be the simplest one and I think it should go
along with some code that will actually use it.

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
