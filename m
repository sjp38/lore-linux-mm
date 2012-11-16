Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 9E1E76B006C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 21:51:34 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 15 Nov 2012 19:51:32 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B86601FF001C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 19:51:26 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAG2pToM213414
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 19:51:29 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAG2pT3O011773
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 19:51:29 -0700
Message-ID: <50A5AA2D.4020003@linux.vnet.ibm.com>
Date: Thu, 15 Nov 2012 18:51:25 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Bug 50181] New: Memory usage doubles after more then 20 hours
 of uptime.
References: <bug-50181-27@https.bugzilla.kernel.org/> <20121113140352.4d2db9e8.akpm@linux-foundation.org> <1352988349.6409.4.camel@c2d-desktop.mypicture.info> <20121115141258.8e5cc669.akpm@linux-foundation.org>
In-Reply-To: <20121115141258.8e5cc669.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Milos Jakovljevic <sukijaki@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

resending to linux-mm@...

On 11/15/2012 02:12 PM, Andrew Morton wrote:
> /proc/slabinfo indicates that it isn't a slab leak, and kmemleak won't
> tell us about alloc_pages() leaks.  I'm stumped.  Dave, any progress at
> your end?

I turned on kmemleak and was able to reproduce this on a second reboot,
but it went most of a workday before I noticed it had leaked a bunch.
Unfortunately, kmemleak didn't help at all.  It found a few small things
that _may_ be leaks, but nothing to account for this _massive_ loss.
I'm stumped so far.

My next step is to add some logging to at least see if this is a gradual
thing or it happens all at once, and maybe figure out what the heck I'm
doing to trigger it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
