Subject: Re: VM tuning through fault trace gathering [with actual code]
References: <Pine.LNX.4.21.0106251456130.7419-100000@imladris.rielhome.conectiva>
From: John Fremlin <vii@users.sourceforge.net>
Date: 25 Jun 2001 22:15:31 +0100
In-Reply-To: <Pine.LNX.4.21.0106251456130.7419-100000@imladris.rielhome.conectiva> (Rik van Riel's message of "Mon, 25 Jun 2001 14:57:39 -0300 (BRST)")
Message-ID: <m28zigi7m4.fsf@boreas.yi.org.>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 25 Jun 2001, John Fremlin wrote:
> 
> > Last year I had the idea of tracing the memory accesses of the
> > system to improve the VM - the traces could be used to test
> > algorithms in userspace. The difficulty is of course making all
> > memory accesses fault without destroying system performance.
> 
> Sounds like a cool idea.  One thing you should keep in mind though
> is to gather traces of the WHOLE SYSTEM and not of individual
> applications.

In the current patch all pagefaults are recorded from all sources. I'd
like to be able to catch read(2) and write(2) (buffer cache stuff) as
well but I don't know how . . . .

> There has to be a way to balance the eviction of pages from
> applications against those of other applications.

Of course! It is important not to regard each thread group as an
independent entity IMHO (had a big old argument about this).

[...]

-- 

	http://ape.n3.net
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
