Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BC866900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 13:40:00 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
References: <alpine.DEB.2.00.1107290145080.3279@tiger>
	<CA+55aFzut1tF6CLAPJUUh2H_7M4wcDpp2+Zb85Lqvofe+3v_jQ@mail.gmail.com>
	<CA+55aFw9V-VM5TBwqdKiP0E_g8urth+08nX-_inZ8N1_gFQF4w@mail.gmail.com>
Date: Sun, 31 Jul 2011 10:39:58 -0700
In-Reply-To: <CA+55aFw9V-VM5TBwqdKiP0E_g8urth+08nX-_inZ8N1_gFQF4w@mail.gmail.com>
	(Linus Torvalds's message of "Sat, 30 Jul 2011 08:32:10 -1000")
Message-ID: <m2livez6vl.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, cl@linux-foundation.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, yinghan@google.com

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Sat, Jul 30, 2011 at 8:27 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> Do we allocate the page map array sufficiently aligned that we
>> actually don't ever have the case of straddling a cacheline? I didn't
>> check.
>
> Oh, and another thing worth checking: did somebody actually check the
> timings for:

I would like to see a followon patch that moves the mem_cgroup
pointer back into struct page. Copying some mem_cgroup people.

>
>  - *just* the alignment change?
>
>    IOW, maybe some of the netperf improvement isn't from the lockless
> path, but exactly from 'struct page' always being in a single
> cacheline?
>
>  - check performance with cmpxchg16b *without* the alignment.
>
>    Sometimes especially intel is so good at unaligned accesses that
> you wouldn't see an issue. Now, locked ops are usually special (and

As Eric pointed out CMPXCHG16B requires alignment, it #GPs otherwise.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
