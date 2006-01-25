From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH/RFC] Shared page tables
Date: Tue, 24 Jan 2006 18:21:07 -0600
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601241743.28889.raybry@mpdtxmail.amd.com>
 <07A9BE6C2CADACD27B259191@[10.1.1.4]>
In-Reply-To: <07A9BE6C2CADACD27B259191@[10.1.1.4]>
MIME-Version: 1.0
Message-ID: <200601241821.07631.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 January 2006 17:50, Dave McCracken wrote:
> Those are interesting numbers.  That's pretty much the showcase for
> sharing, yeah.
>
<snip>
> I must mention here that I think most DB performance suites do their forks
> up front, then never fork during the test, so fork performance doesn't
> really factor in as much.  There are other reasons shared page tables helps
> there, though.
>

Yes, that's why I mentioned the DB workloads as being more interesting.

> > Now I am off to figure out how Andi's mmap() randomization patch
> > interacts  with all of this stuff.
>
> mmap() randomization doesn't affect fork at all, since by definition all
> regions are at the same address in the child as the parent (ie good for
> sharing).  The trickier case is where processes independently mmap() a
> region.
>
> Dave
>

Hmm... I agree with your previous comment there, then.   The only way the big 
DB guys can start up that way is if they use MAP_FIXED and a pre-agreed on 
address.   Otherwise, they can't do lookups of DB buffers in the shared 
storage area (i. e. this is basically user space buffer cache management).  
It has to be the case that they all agree on what addresses the buffers are 
at so each process can share the buffers.

So, that would argue that the mmap() randomization can't effect them either, 
without breaking the existing API.
-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
