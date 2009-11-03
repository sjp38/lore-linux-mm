Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D9E8F6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 16:11:12 -0500 (EST)
Message-ID: <4AF09CB2.9030500@crca.org.au>
Date: Wed, 04 Nov 2009 08:12:18 +1100
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: [PATCHv2 2/5] vmscan: Kill hibernation specific reclaim logic
 and unify it
References: <20091102000855.F404.A69D9226@jp.fujitsu.com> <20091103002520.886C.A69D9226@jp.fujitsu.com> <4AEF4CF1.3020500@crca.org.au> <200911031230.20344.rjw@sisk.pl>
In-Reply-To: <200911031230.20344.rjw@sisk.pl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Rafael.

Rafael J. Wysocki wrote:
> On Monday 02 November 2009, Nigel Cunningham wrote:
>> Hi.
> 
> Hi,
> 
>> KOSAKI Motohiro wrote:
>>>> I haven't given much thought to numa awareness in hibernate code, but I
>>>> can say that the shrink_all_memory interface is woefully inadequate as
>>>> far as zone awareness goes. Since lowmem needs to be atomically restored
>>>> before we can restore highmem, we really need to be able to ask for a
>>>> particular number of pages of a particular zone type to be freed.
>>> Honestly, I am not suspend/hibernation expert. Can I ask why caller need to know
>>> per-zone number of freed pages information? if hibernation don't need highmem.
>>> following incremental patch prevent highmem reclaim perfectly. Is it enough?
>> (Disclaimer: I don't think about highmem a lot any more, and might have
>> forgotten some of the details, or swsusp's algorithms might have
>> changed. Rafael might need to correct some of this...)
>>
>> Imagine that you have a system with 1000 pages of lowmem and 5000 pages
>> of highmem. Of these, 950 lowmem pages are in use and 500 highmem pages
>> are in use.
>>
>> In order to to be able to save an image, we need to be able to do an
>> atomic copy of those lowmem pages.
>>
>> You might think that we could just copy everything into the spare
>> highmem pages, but we can't because mapping and unmapping the highmem
>> pages as we copy the data will leave us with an inconsistent copy.
> 
> This isn't the case any more for the mainline hibernate code.  We use highmem
> for storing image data as well as lowmem.

Highmem for storing copies of lowmem pages?

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
