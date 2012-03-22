Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 421026B00F5
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:57:53 -0400 (EDT)
Date: Thu, 22 Mar 2012 21:57:45 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
Message-ID: <20120322215744.GF6589@ZenIV.linux.org.uk>
References: <20120321065140.13852.52315.stgit@zurg>
 <20120321100602.GA5522@barrios>
 <4F69D496.2040509@openvz.org>
 <20120322142647.42395398.akpm@linux-foundation.org>
 <20120322212810.GE6589@ZenIV.linux.org.uk>
 <20120322144122.59d12051.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120322144122.59d12051.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

On Thu, Mar 22, 2012 at 02:41:22PM -0700, Andrew Morton wrote:
> On Thu, 22 Mar 2012 21:28:11 +0000
> Al Viro <viro@ZenIV.linux.org.uk> wrote:
> 
> > On Thu, Mar 22, 2012 at 02:26:47PM -0700, Andrew Morton wrote:
> > > It would be nice to find some way of triggering compiler warnings or
> > > sparse warnings if someone mixes a 32-bit type with a vm_flags_t.  Any
> > > thoughts on this?
> > > 
> > > (Maybe that's what __nocast does, but Documentation/sparse.txt doesn't
> > > describe it)
> > 
> > Use __bitwise for that - check how gfp_t is handled.
> 
> So what does __nocast do?

Not much...  Basically, extending conversions.  __nocast int can be
freely mixed with int - no complaints will be given.

As far as I'm concerned, it's deprecated - it's weaker than __bitwise and
doesn't have particulary useful semantics.  For this kind of stuff (flags)
__bitwise is definitely better - that's what it had been implemented for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
