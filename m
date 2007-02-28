Date: Wed, 28 Feb 2007 09:35:26 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Remove page flags for software suspend
In-Reply-To: <200702281833.03914.rjw@sisk.pl>
Message-ID: <Pine.LNX.4.64.0702280932160.5371@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
 <200702281813.04643.rjw@sisk.pl> <Pine.LNX.4.64.0702280915030.3263@schroedinger.engr.sgi.com>
 <200702281833.03914.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Feb 2007, Rafael J. Wysocki wrote:

> Yes, I know that.  On the other hand, we have terminally broken CPU hotplug
> code in the kernel that I'd like to get fixed _first_.

The cpu hotplug code has been terminal for years.

> PageNosaveFree is only needed at the suspend time, so we need not allocate
> it in advance.

Well it should be simple to change the patch to allocate the bitmaps 
later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
