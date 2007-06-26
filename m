Message-ID: <46807B5D.6090604@yahoo.com.au>
Date: Tue, 26 Jun 2007 12:35:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: vm/fs meetup in september?
References: <20070624042345.GB20033@wotan.suse.de> <20070625063545.GA1964@infradead.org>
In-Reply-To: <20070625063545.GA1964@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Sun, Jun 24, 2007 at 06:23:45AM +0200, Nick Piggin wrote:
> 
>>I'd just like to take the chance also to ask about a VM/FS meetup some
>>time around kernel summit (maybe take a big of time during UKUUG or so).
> 
> 
> I won't be around until a day or two before KS, so I'd prefer to have it
> after KS if possible.

I'd like to see you there, so I hope we can find a date that most
people are happy with. I'll try to start working that out after we
have a rough idea of who's interested.


>>I don't want to do it in the VM summit, because that kind of alienates
>>the filesystem guys. What I want to talk about is anything and everything
>>that the VM can do better to help the fs and vice versa.  I'd like to
>>stay away from memory management where not too applicable to the fs.
> 
> 
> As more of a filesystem person I wouldn't mind it being attached to a VM
> conf.  In the worst case we'll just rename it VM/FS conference.  When and
> where is it scheduled?

I'll just cc Martin, however the VM conference I think is pretty short
on filesystem people. I'd also like to avoid a lot of VM topics and
hopefully have enough time for a topic of interest or so from each fs
maintainer who has something to talk about.

But I'm open to ideas that will make it work better. FWIW, Anton has
offered to try arranging conference facilities at the university, so
I think we should be covered there.


>>- the address space operations APIs, and their page based nature. I think
>>  it would be nice to generally move toward offset,length based ones as
>>  much as possible because it should give more efficiency and flexibility
>>  in the filesystem.
>>
>>- write_begin API if it is still an issue by that date. Hope not :)
>>
>>- truncate races
>>
>>- fsblock if it hasn't been shot down by then
> 
> 
> Don't forget high order pagecache please.


Leaving my opinion of higher order pagecache aside, this _may_ be an
example of something that doesn't need a lot of attention, because it
should be fairly uncontroversial from a filesystem's POV? (eg. it is
more a relevant item to memory management and possibly block layer).
OTOH if it is discussed in the context of "large blocks in the buffer
layer is crap because we can do it with higher order pagecache", then
that might be interesting :)

Anyway, I won't say no to any proposal, so keep the ideas coming. We
can talk about whatever we find interesting on the day.


>>- how to make complex API changes without having to fix most things
>>  yourself.
> 
> 
> More issues:

Thanks Christoph, sounds good.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
