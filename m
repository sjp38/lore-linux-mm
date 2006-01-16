Subject: Re: differences between MADV_FREE and MADV_DONTNEED
References: <20051102014321.GG24051@opteron.random>
	<1130947957.24503.70.camel@localhost.localdomain>
	<20051111162511.57ee1af3.akpm@osdl.org>
	<1131755660.25354.81.camel@localhost.localdomain>
	<20051111174309.5d544de4.akpm@osdl.org> <43757263.2030401@us.ibm.com>
	<20060116130649.GE15897@opteron.random> <43CBC37F.60002@FreeBSD.org>
	<20060116162808.GG15897@opteron.random> <43CBD1C4.5020002@FreeBSD.org>
	<20060116172449.GL15897@opteron.random>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 16 Jan 2006 14:43:47 -0700
In-Reply-To: <20060116172449.GL15897@opteron.random> (Andrea Arcangeli's
 message of "Mon, 16 Jan 2006 18:24:49 +0100")
Message-ID: <m1r777rgq4.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Suleiman Souhlal <ssouhlal@FreeBSD.org>, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, hugh@veritas.com, dvhltc@us.ibm.com, linux-mm@kvack.org, blaisorblade@yahoo.it, jdike@addtoit.com
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> writes:

> On Mon, Jan 16, 2006 at 09:03:00AM -0800, Suleiman Souhlal wrote:
>> Andrea Arcangeli wrote:
>> 
>> >We can also use it for the same purpose, we could add the pages to
>> >swapcache mark them dirty and zap the ptes _after_ that.
>> 
>> Wouldn't that cause the pages to get swapped out immediately?
>
> Not really, it would be a non blocking operation. But they could be
> swapped out shortly later (that's the whole point of DONTNEED, right?),
> once there is more memory pressure. Otherwise if they're used again, a
> minor fault will happen and it will find the swapcache uptodate in ram.

As I recall the logic with DONTNEED was to mark the mapping of
the page clean so the page didn't need to be swapped out, it could
just be dropped.

That is why they anonymous and the file backed cases differ.

Part of the point is to avoid the case of swapping the pages out if
the application doesn't care what is on them anymore.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
