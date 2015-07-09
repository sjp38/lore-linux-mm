Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 520246B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 13:49:06 -0400 (EDT)
Received: by igoe12 with SMTP id e12so19202158igo.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 10:49:06 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id l1si23479843igx.50.2015.07.09.10.49.05
        for <linux-mm@kvack.org>;
        Thu, 09 Jul 2015 10:49:05 -0700 (PDT)
Message-ID: <559EB411.2040009@sgi.com>
Date: Thu, 9 Jul 2015 12:49:05 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages before
 basic setup
References: <20150624225028.GA97166@asylum.americas.sgi.com> <1436204750.29787.3@cpanel21.proisp.no>
In-Reply-To: <1436204750.29787.3@cpanel21.proisp.no>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel J Blueman <daniel@numascale.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

Interesting, I found a small improvement in total clock time through the 
area.
I tweaked page_alloc_init_late have a timer, like the 
deferred_init_memmap, and this patch showed a small improvement.

Ok thanks for your help.


On 07/06/2015 12:45 PM, Daniel J Blueman wrote:
> Hi Nate,
>
> On Wed, Jun 24, 2015 at 11:50 PM, Nathan Zimmer <nzimmer@sgi.com> wrote:
>> My apologies for taking so long to get back to this.
>>
>> I think I did locate two potential sources of slowdown.
>> One is the set_cpus_allowed_ptr as I have noted previously.
>> However I only notice that on the very largest boxes.
>> I did cobble together a patch that seems to help.
>>
>> The other spot I suspect is the zone lock in free_one_page.
>> I haven't been able to give that much thought as of yet though.
>>
>> Daniel do you mind seeing if the attached patch helps out?
>
> Just got back from travel, so apologies for the delays.
>
> The patch doesn't mitigate the increasing initialisation time; summing 
> the per-node times for an accurate measure, there was a total of 
> 171.48s before the patch and 175.23s after. I double-checked and got 
> similar data.
>
> Thanks,
>  Daniel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
