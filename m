Date: Mon, 25 Jun 2001 14:57:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM tuning through fault trace gathering [with actual code]
In-Reply-To: <m2d77s4m34.fsf@boreas.yi.org.>
Message-ID: <Pine.LNX.4.21.0106251456130.7419-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@users.sourceforge.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 25 Jun 2001, John Fremlin wrote:

> Last year I had the idea of tracing the memory accesses of the system
> to improve the VM - the traces could be used to test algorithms in
> userspace. The difficulty is of course making all memory accesses
> fault without destroying system performance.

Sounds like a cool idea.  One thing you should keep in mind
though is to gather traces of the WHOLE SYSTEM and not of
individual applications.

There has to be a way to balance the eviction of pages from
applications against those of other applications.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
