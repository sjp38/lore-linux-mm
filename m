From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Remove page flags for software suspend
Date: Wed, 28 Feb 2007 18:33:03 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200702281813.04643.rjw@sisk.pl> <Pine.LNX.4.64.0702280915030.3263@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702280915030.3263@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200702281833.03914.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday, 28 February 2007 18:17, Christoph Lameter wrote:
> On Wed, 28 Feb 2007, Rafael J. Wysocki wrote:
> 
> > As I have already said for a couple of times, I think we can and I'm going to
> > do it, but right now I'm a bit busy with other things that I consider as more
> > urgent.
> 
> Ummm.. There are other parties who would like to use these flags!

Yes, I know that.  On the other hand, we have terminally broken CPU hotplug
code in the kernel that I'd like to get fixed _first_.

> I think my patch localizes the suspend material properly. In fact there 
> is *no* reason for the page flags to be visible outside of snapshot.c.

Yes, there is.  PageNosave should be visible to the architectures so that they
can mark nosave pages for the suspend.

> What is the problem with the patch?

PageNosaveFree is only needed at the suspend time, so we need not allocate
it in advance.
 
> How long will it take you to remove the flags on your own?

I can't promise anything, because that also depends on people who work
on the CPU hotplug, workqueues etc. and these things are hard.  I'll do that
as soon as I can.

Greetings,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
