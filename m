From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH/RFC] Shared page tables
Date: Mon, 23 Jan 2006 18:46:07 -0600
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601231758.08397.raybry@mpdtxmail.amd.com>
 <6BC41571790505903C7D3CD6@[10.1.1.4]>
In-Reply-To: <6BC41571790505903C7D3CD6@[10.1.1.4]>
MIME-Version: 1.0
Message-ID: <200601231846.08594.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 23 January 2006 18:19, Dave McCracken wrote:
<snip>
>
> The basic rule for pte sharing is that some portion of a memory region must
> span an entire pte page.  For i386 and x96_64 that would be 2 meg.  The
> region must either be read-only or marked to be shared if it is writeable.
>

Yeah, I figured that out just after hitting "send" on that first note.  :-(

> The code does opportunistically look for any pte page that is fully within
> a shareable vma, and will share if it finds one.
>
> Oh, and one more caveat.  The region must be mapped to the same address in
> each process.
>
> > I turned on the PT_DEBUG stuff, but thus far have found no evidence of
> > pte  sharing actually occurring in a normal system boot.  I'm surprised
> > by that as  I (naively?) would have expected shared libraries to use
> > shared ptes.
>

OK, with those guidelines I can put together a test program pretty quickly.
If you have one handy that would be fine, but don't put a lot of effort into 
it.

Thanks,

> Most system software, including the shared libraries, don't have any
> regions that are big enough for sharing (the text section for libc, for
> example, is about 1.5 meg).
>

Ah, that explains that then.

> Dave McCracken

-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
