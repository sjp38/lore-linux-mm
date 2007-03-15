Date: Thu, 15 Mar 2007 21:07:39 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
Message-ID: <20070315200739.GD19625@wotan.suse.de>
References: <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <45F96CCB.4000709@redhat.com> <20070315162944.GI8321@wotan.suse.de> <Pine.GSO.4.64.0703151532530.29483@cpu102.cs.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.64.0703151532530.29483@cpu102.cs.uwaterloo.ca>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashif Harji <asharji@cs.uwaterloo.ca>
Cc: Chuck Ebbert <cebbert@redhat.com>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 03:55:08PM -0400, Ashif Harji wrote:
> 
> It sounds like people are happy with the fix suggested by Nick.  That fix 
> is okay with me as it fixes the problem I am having.
> 
> I suspect, however, that by not directly detecting the problematic access 
> pattern, where the file is accessed sequentially in small hunks, other 
> applications may experience performance problems related to caching. For 
> example, if an application frequently and non-sequentially reads from the 
> same page.  This is especially true for files of size < PAGE_CACHE_SIZE.
> But, I'm not sure if such an access pattern likely.

Well in general we like to help applications that help themselves. It
is actually a good heuristic, surprisingly. If an application randomly
accesses the same page (and there is no write activity going on), then
it would be better off to cache it in userspace, and if it doesn't care
to do that then it won't mind having to read it off disk now and again :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
