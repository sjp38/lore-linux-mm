Date: Tue, 31 Aug 1999 13:10:46 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: accel handling
In-Reply-To: <14283.53075.795656.291744@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9908311307451.14957-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, Vladimir Dergachev <vdergach@sas.upenn.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> On Tue, 31 Aug 1999 12:55:26 +0200, Marcus Sundberg
> <erammsu@kieraypc01.p.y.ki.era.ericsson.se> said:
> 
> > But by only re-mapping the framebuffer on demand as Stephen said you
> > can avoid repeatedly un-mapping the framebuffer for processes/threads
> > that doesn't use it.
> 
> Yes.  The biggest problem is that the VM currently has no support for
> demand-paging of an entire framebuffer region, and taking a separate
> page fault to fault back the mapping of every page in the framebuffer
> would be too slow.  As long as we can switch the entire framebuffer in
> and out of the mapping rapidly, things aren't too bad.
>

So if this is the problem could we write a special routine that optimizes
this. What if we gave the VM support for demand paging of an entire
framebuffer region.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
