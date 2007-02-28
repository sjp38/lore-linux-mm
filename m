From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Remove page flags for software suspend
Date: Wed, 28 Feb 2007 18:51:51 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200702281833.03914.rjw@sisk.pl> <Pine.LNX.4.64.0702280932160.5371@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702280932160.5371@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200702281851.51666.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday, 28 February 2007 18:35, Christoph Lameter wrote:
> On Wed, 28 Feb 2007, Rafael J. Wysocki wrote:
> 
> > Yes, I know that.  On the other hand, we have terminally broken CPU hotplug
> > code in the kernel that I'd like to get fixed _first_.
> 
> The cpu hotplug code has been terminal for years.

But recently it's been becoming a real pain.

> > PageNosaveFree is only needed at the suspend time, so we need not allocate
> > it in advance.
> 
> Well it should be simple to change the patch to allocate the bitmaps 
> later.

Well, yes, I think so.  Still, there may be another way of doing it and I need
some time to have a look.

BTW, have you tested the patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
