Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <Pine.LNX.4.44.0207071119130.3271-100000@home.transmeta.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 08 Jul 2002 04:15:04 -0600
In-Reply-To: <Pine.LNX.4.44.0207071119130.3271-100000@home.transmeta.com>
Message-ID: <m1adp2r0ev.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Martin J. Bligh" <fletch@aracnet.com>, Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> Hmm.. Right now we have the same IDT and GDT on all CPU's, so _if_ the CPU
> is stupid enough to do a locked cycle to update the "A" bit on the
> segments (even if it is already set), you would see horrible cacheline
> bouncing for any interrupt.
> 
> I don't know if that is the case. I'd _assume_ that the microcode was
> clever enough to not do this, but who knows. It should be fairly easily
> testable (just "SMOP") by duplicating the IDT/GDT across CPU's.

If you don't carry about the "A" bit and I don't think we do this is
trivial preventable.  You can set when you initialize the GDT/IDT and
it will never be updated.

I had to make this change a while ago in LinuxBIOS because P4's lock up
when you load a GDT from a ROM that doesn't have the accessed bit set.

The fact it doesn't lock up is a fairly good proof that no writes happen
when the accessed bit is already set.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
