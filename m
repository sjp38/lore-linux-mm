Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 16B7E6B004D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 00:10:10 -0500 (EST)
Message-ID: <50EBAA27.7030506@zytor.com>
Date: Mon, 07 Jan 2013 21:09:59 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC]x86: clearing access bit don't flush tlb
References: <20130107081213.GA21779@kernel.org> <50EAE66B.1020804@redhat.com> <50EB4CB9.9010104@zytor.com> <20130108045519.GB2459@kernel.org> <50EBA8AB.2060003@zytor.com> <50EBA9DC.9070400@redhat.com>
In-Reply-To: <50EBA9DC.9070400@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com, hughd@google.com

On 01/07/2013 09:08 PM, Rik van Riel wrote:
> On 01/08/2013 12:03 AM, H. Peter Anvin wrote:
>> On 01/07/2013 08:55 PM, Shaohua Li wrote:
>>>
>>> I searched a little bit, the change (doing TLB flush to clear access
>>> bit) is
>>> made between 2.6.7 - 2.6.8, I can't find the changelog, but I found a
>>> patch:
>>> http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.7-rc2/2.6.7-rc2-mm2/broken-out/mm-flush-tlb-when-clearing-young.patch
>>>
>>>
>>> The changelog declaims this is for arm/ppc/ppc64.
>>>
>>
>> Not really.  It says that those have stumbled over it already.  It is
>> true in general that this change will make very frequently used pages
>> (which stick in the TLB) candidates for eviction.
> 
> That is only true if the pages were to stay in the TLB for a
> very very long time.  Probably multiple seconds.
> 
>> x86 would seem to be just as affected, although possibly with a
>> different frequency.
>>
>> Do we have any actual metrics on anything here?
> 
> I suspect that if we do need to force a TLB flush for page
> reclaim purposes, it may make sense to do that TLB flush
> asynchronously. For example, kswapd could kick off a TLB
> flush of every CPU in the system once a second, when the
> system is under pageout pressure.
> 
> We would have to do this in a smart way, so the kswapds
> from multiple nodes do not duplicate the work.
> 
> If people want that kind of functionality, I would be
> happy to cook up an RFC patch.
> 

So it sounds like you're saying that this patch should never have been
applied in the first place?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
