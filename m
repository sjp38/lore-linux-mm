Date: Thu, 11 Jul 2002 17:05:46 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Optimize out pte_chain take three
In-Reply-To: <3D2DE264.17706BB4@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207111703080.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2002, Andrew Morton wrote:

> Rik thought these are pagecache and swap thrashers, but that's not
> the intent.  Think of the file as program text and the malloced
> memory as, well, malloced memory.
>
> The problem is the access pattern.  It shouldn't be random-uniform.
> But what should it be?  random-gaussian?

> Does this not capture what the VM is supposed to do?

Indeed. This sounds like a much much better test.


> useful pagecache and swapping everything out.  Our kernels have
> O_STREAMING because of this.   It simply removes as much pagecache
> as it can, each time ->nrpages reaches 256.  It's rather effective.

Now why does that remind me of drop-behind ? ;)


> I installed 2.5.25+rmap on my desktop yesterday.  Come in this morning
> to discover half of memory is inodes, quarter of memory is dentries and
> I'm 40 megs into swap.  Sigh.

As requested by Linus, this patch only has the mechanism
and none of the balancing changes.

I suspect Ed Tomlinson's patch will fix this issue.


> The `working set simulator' could provide the memory hog function.
> The victim application perhaps doesn't need to be anything as
> fancy on day one.  Maybe just a kernel compile or such?

Or maybe the interactive performance measurement thing by
Bob Matthews ?

	http://people.redhat.com/bmatthews/irman/ (IIRC)

> I'll do the working set simulator.  That'll give you guys something
> to crunch on.  Is gaussian reasonable?

Sounds ok to me.

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
