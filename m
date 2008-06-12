Date: Thu, 12 Jun 2008 12:20:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: repeatable slab corruption with LTP msgctl08
Message-Id: <20080612122009.f4d3a82a.akpm@linux-foundation.org>
In-Reply-To: <48517456.5000901@colorfullife.com>
References: <20080611221324.42270ef2.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0806121332130.11556@sbz-30.cs.Helsinki.FI>
	<48516BF3.8050805@colorfullife.com>
	<20080612114152.18895d6c.akpm@linux-foundation.org>
	<48517456.5000901@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: penberg@cs.helsinki.fi, Nadia.Derbey@bull.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 21:09:10 +0200
Manfred Spraul <manfred@colorfullife.com> wrote:

> Either someone does a set_bit() or your cpu is breaking down.

Well.  It is about ten years old.  But this is the first sign of a
problem and it's always msgctl08.

>  From looking at the the msgctl08 test: it shouldn't produce any races, 
> it just does lots of bulk msgsnd()/msgrcv() operations. Always one 
> thread sends, one thread receives on each queue. It's probably more a 
> scheduler stresstest than anything else.
> 
> Attached is a completely untested patch:
> - add 8 bytes to each slabp struct: This changes the alignment of the 
> bufctl entries.
> - add a hexdump of the redzone bytes.

OK, I'll try that this evening (eight hours hence).

I'll also try increasing /proc/sys/kernel/msgmni under 2.6.25.

> Andrew: how do you log the oops? 
> it might scroll of the screen.

netconsole-to-disk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
