Date: Wed, 28 Feb 2007 09:17:52 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Remove page flags for software suspend
In-Reply-To: <200702281813.04643.rjw@sisk.pl>
Message-ID: <Pine.LNX.4.64.0702280915030.3263@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
 <20070228101403.GA8536@elf.ucw.cz> <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com>
 <200702281813.04643.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Feb 2007, Rafael J. Wysocki wrote:

> As I have already said for a couple of times, I think we can and I'm going to
> do it, but right now I'm a bit busy with other things that I consider as more
> urgent.

Ummm.. There are other parties who would like to use these flags!

I think my patch localizes the suspend material properly. In fact there 
is *no* reason for the page flags to be visible outside of snapshot.c.
What is the problem with the patch?

How long will it take you to remove the flags on your own?
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
