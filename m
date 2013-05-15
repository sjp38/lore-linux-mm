Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 9CC446B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 16:45:22 -0400 (EDT)
Message-ID: <5193F3CC.8020205@redhat.com>
Date: Wed, 15 May 2013 16:45:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv11 3/4] zswap: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com> <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com> <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default> <20130514163541.GC4024@medulla> <f0272a06-141a-4d33-9976-ee99467f3aa2@default> <20130514225501.GA11956@cerebellum> <4d74f5db-11c1-4f58-97f4-8d96bbe601ac@default> <20130515185506.GA23342@phenom.dumpdata.com> <57917f43-ab37-4e82-b659-522e427fda7f@default>
In-Reply-To: <57917f43-ab37-4e82-b659-522e427fda7f@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 05/15/2013 03:35 PM, Dan Magenheimer wrote:
>> From: Konrad Rzeszutek Wilk
>> Subject: Re: [PATCHv11 3/4] zswap: add to mm/
>>
>>> Sorry, but I don't think that's appropriate for a patch in the MM subsystem.
>>
>> I am heading to the airport shortly so this email is a bit hastily typed.
>>
>> Perhaps a compromise can be reached where this code is merged as a driver
>> not a core mm component. There is a high bar to be in the MM - it has to
>> work with many many different configurations.
>>
>> And drivers don't have such a high bar. They just need to work on a specific
>> issue and that is it. If zswap ended up in say, drivers/mm that would make
>> it more palpable I think.
>>
>> Thoughts?
>
> Hmmm...
>
> To me, that sounds like a really good compromise.

Come on, we all know that is nonsense.

Sure, the zswap and zbud code may not be in their final state yet,
but they belong in the mm/ directory, together with the cleancache
code and all the other related bits of code.

Lets put them in their final destination, and hope the code attracts
attention by as many MM developers as can spare the time to help
improve it.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
