From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14284.8851.865175.995828@dukat.scot.redhat.com>
Date: Tue, 31 Aug 1999 19:44:35 +0100 (BST)
Subject: Re: accel handling
In-Reply-To: <Pine.LNX.4.10.9908311307451.14957-100000@imperial.edgeglobal.com>
References: <14283.53075.795656.291744@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9908311307451.14957-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, Vladimir Dergachev <vdergach@sas.upenn.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 31 Aug 1999 13:10:46 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

>> Yes.  The biggest problem is that the VM currently has no support for
>> demand-paging of an entire framebuffer region, and taking a separate
>> page fault to fault back the mapping of every page in the framebuffer
>> would be too slow.  As long as we can switch the entire framebuffer in
>> and out of the mapping rapidly, things aren't too bad.
>> 

> So if this is the problem could we write a special routine that optimizes
> this. What if we gave the VM support for demand paging of an entire
> framebuffer region.  

You cut out the most important part of my email, which was that such
support would be prohibitively expensive for any graphics-intensive
applications.  It is only feasible if there is a very low rate of
switching between accel and framebuffer access.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
