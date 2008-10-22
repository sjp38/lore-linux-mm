From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
References: <87d4hugrwm.fsf@saeurebad.de>
	<20081021104357.GA12329@wotan.suse.de>
	<878wsigp2e.fsf_-_@saeurebad.de>
	<20081021151342.c1678bd6.akpm@linux-foundation.org>
Date: Wed, 22 Oct 2008 02:09:28 +0200
In-Reply-To: <20081021151342.c1678bd6.akpm@linux-foundation.org> (Andrew
	Morton's message of "Tue, 21 Oct 2008 15:13:42 -0700")
Message-ID: <87r669fq2v.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@suse.de, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue, 21 Oct 2008 13:33:45 +0200
> Johannes Weiner <hannes@saeurebad.de> wrote:
>
>> File pages mapped only in sequentially read mappings are perfect
>> reclaim canditates.
>> 
>> This makes MADV_SEQUENTIAL mappings behave like a weak references,
>> their pages will be reclaimed unless they have a strong reference from
>> a normal mapping as well.
>> 
>> The patch changes the reclaim and the unmap path where they check if
>> the page has been referenced.  In both cases, accesses through
>> sequentially read mappings will be ignored.
>> 
>> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
>> ---
>> II: add likely()s to mitigate the extra branches a bit as to Nick's
>>     suggestion
>
> Is http://hannes.saeurebad.de/madvseq/ still true with this version?

No, sorry, still running benchmarks on this version.  Coming up soon...

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
