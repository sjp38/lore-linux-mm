Date: Fri, 14 Nov 2003 13:47:55 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: 2.6.0-test9-mm3
In-Reply-To: <103290000.1068847073@flay>
Message-ID: <Pine.LNX.4.44.0311141344290.5877-100000@home.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Zwane Mwaikambo <zwane@arm.linux.org.uk>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Nov 2003, Martin J. Bligh wrote:
> 
> Linus had some debug thing for triple faults, a few months ago, IIRC ...
> probably in the archives somewhere ...

Triple faults you can't debug, they raise a line outside the CPU, and 
normal PC hardware will cause that to just trigger a reboot.

But double faults do get caught, and that debugging stuff actually is in
the standard kernel. It won't give _nearly_ as good a debug report as a
"normal" oops, since I didn't want the double-fault handler to touch
anything even remotely unsafe, but it often gives a good hint about what
might be wrong. Certainly better than triple-faulting did (which we still
do for _catastrophic_ corruption, eg totally munged kernel page tables etc
- it's just very hard to avoid once you get corrupted enough).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
