Date: Thu, 15 Mar 2007 21:31:59 +0100
From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
Message-ID: <20070315203159.GA15463@rhlx01.hs-esslingen.de>
References: <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <45F96CCB.4000709@redhat.com> <20070315162944.GI8321@wotan.suse.de> <Pine.GSO.4.64.0703151532530.29483@cpu102.cs.uwaterloo.ca> <20070315200739.GD19625@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070315200739.GD19625@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Ashif Harji <asharji@cs.uwaterloo.ca>, Chuck Ebbert <cebbert@redhat.com>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Mar 15, 2007 at 09:07:39PM +0100, Nick Piggin wrote:
> Well in general we like to help applications that help themselves. It
> is actually a good heuristic, surprisingly. If an application randomly
> accesses the same page (and there is no write activity going on), then
> it would be better off to cache it in userspace, and if it doesn't care
> to do that then it won't mind having to read it off disk now and again :)

Sounds like a good plan since this probably is a nice way to make stupid apps
doing stupid things sit up and take notice, and maybe the authors will then go
so far as fixing up a few more things that are hurting them once they actually
recognize that something is weird due to overly bad performance.

Why go to great lengths to support stupid apps when there are still so many things
which could be done to help well-behaving ones? ;)

Andreas Mohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
