From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [PATCH -mm 08/14] bootmem: clean up alloc_bootmem_core
References: <20080530194220.286976884@saeurebad.de>
	<20080530194738.789921715@saeurebad.de>
Date: Sat, 31 May 2008 00:11:43 +0200
In-Reply-To: <20080530194738.789921715@saeurebad.de> (Johannes Weiner's
	message of "Fri, 30 May 2008 21:42:28 +0200")
Message-ID: <87ej7jmogw.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Johannes Weiner <hannes@saeurebad.de> writes:

> alloc_bootmem_core has become quite nasty to read over time.  This is
> a clean rewrite that keeps the semantics.

Another ->last_success error (missed updating it).

I already have a fixed up series here, will wait a bit for sending it
out to incorporate feedback as well.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
