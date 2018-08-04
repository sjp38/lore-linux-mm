Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8644D6B026B
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 10:00:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v9-v6so5328889pff.4
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 07:00:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14-v6sor2029790pgv.306.2018.08.04.07.00.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 Aug 2018 07:00:39 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
References: <20180411060320.14458-1-willy@infradead.org>
 <20180411060320.14458-3-willy@infradead.org>
 <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake>
 <20180411192448.GD22494@bombadil.infradead.org>
 <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
 <20180411235652.GA28279@bombadil.infradead.org>
 <alpine.DEB.2.20.1804120907100.11220@nuc-kabylake>
 <20180412142718.GA20398@bombadil.infradead.org>
 <20180412191322.GA21205@bombadil.infradead.org>
 <20180803212257.GA5922@roeck-us.net>
 <20180803223357.GA23284@bombadil.infradead.org>
 <CAMuHMdXXYH_7oVJJ5sGWFj_-WbjuMdooXTqBfV+z0CzR193T3A@mail.gmail.com>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <e14d7aea-233d-57ae-c1e2-1d14369dd305@roeck-us.net>
Date: Sat, 4 Aug 2018 07:00:35 -0700
MIME-Version: 1.0
In-Reply-To: <CAMuHMdXXYH_7oVJJ5sGWFj_-WbjuMdooXTqBfV+z0CzR193T3A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Matthew Wilcox <willy@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, Mel Gorman <mgorman@techsingularity.net>, Linux-sh list <linux-sh@vger.kernel.org>

On 08/04/2018 02:28 AM, Geert Uytterhoeven wrote:
> On Sat, Aug 4, 2018 at 12:34 AM Matthew Wilcox <willy@infradead.org> wrote:
>> On Fri, Aug 03, 2018 at 02:22:57PM -0700, Guenter Roeck wrote:
>>> On Thu, Apr 12, 2018 at 12:13:22PM -0700, Matthew Wilcox wrote:
>>>> From: Matthew Wilcox <mawilcox@microsoft.com>
>>>> __GFP_ZERO requests that the object be initialised to all-zeroes,
>>>> while the purpose of a constructor is to initialise an object to a
>>>> particular pattern.  We cannot do both.  Add a warning to catch any
>>>> users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
>>>> a constructor.
>>>>
>>>> Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
>>>> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
>>>> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>>>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>>> Acked-by: Michal Hocko <mhocko@suse.com>
>>>
>>> Seen with v4.18-rc7-139-gef46808 and v4.18-rc7-178-g0b5b1f9a78b5 when
>>> booting sh4 images in qemu:
>>
>> Thanks!  It's under discussion here:
>>
>> https://marc.info/?t=153301426900002&r=1&w=2
> 
> and https://www.spinics.net/lists/linux-sh/msg53298.html
> 
>> also reported here with a bogus backtrace:
>>
>> https://marc.info/?l=linux-sh&m=153305755505935&w=2
>>
>> Short version: It's a bug that's been present since 2009 and nobody
>> noticed until now.  And nobody's quite sure what the effect of this
>> bug is.

Though now it is making a lot of noise :-).

I just found two more 0-day bugs, so maybe improved testing and log messages
such as the one encountered here do help a bit.

Guenter
