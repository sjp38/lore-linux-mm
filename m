Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id C06BD6B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:41:24 -0400 (EDT)
Date: Thu, 22 Mar 2012 14:41:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
Message-Id: <20120322144122.59d12051.akpm@linux-foundation.org>
In-Reply-To: <20120322212810.GE6589@ZenIV.linux.org.uk>
References: <20120321065140.13852.52315.stgit@zurg>
	<20120321100602.GA5522@barrios>
	<4F69D496.2040509@openvz.org>
	<20120322142647.42395398.akpm@linux-foundation.org>
	<20120322212810.GE6589@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

On Thu, 22 Mar 2012 21:28:11 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Thu, Mar 22, 2012 at 02:26:47PM -0700, Andrew Morton wrote:
> > It would be nice to find some way of triggering compiler warnings or
> > sparse warnings if someone mixes a 32-bit type with a vm_flags_t.  Any
> > thoughts on this?
> > 
> > (Maybe that's what __nocast does, but Documentation/sparse.txt doesn't
> > describe it)
> 
> Use __bitwise for that - check how gfp_t is handled.

So what does __nocast do?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
