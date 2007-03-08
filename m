From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re: Remove page flags for software suspend)
Date: Thu, 8 Mar 2007 23:10:14 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200703041450.02178.rjw@sisk.pl> <1173366543.3248.1.camel@johannes.berg>
In-Reply-To: <1173366543.3248.1.camel@johannes.berg>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703082310.15297.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>, Pavel Machek <pavel@ucw.cz>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thursday, 8 March 2007 16:09, Johannes Berg wrote:
> 
> > Okay, the next three messages contain patches that should do the trick.
> > 
> > They have been tested on x86_64, but not very thoroughly.
> 
> Works on my powerbook as well. Never mind that usb is broken again with
> suspend to disk. And my own patches break both str and std right now.

Ouch.

> But these (on top of wireless-dev which is currently about 2.6.21-rc2)
> work fine as long as I assume they don't break usb ;)

Well, on my boxes they don't. ;-)

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
