Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7BC66B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 02:27:36 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so11267716wml.0
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 23:27:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si2670971wmi.89.2016.08.18.23.27.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 23:27:35 -0700 (PDT)
Subject: Re: OOM killer changes
References: <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
 <20160815150123.GG3360@dhcp22.suse.cz>
 <1b8ee89d-a851-06f0-6bcc-62fef9e7e7cc@Quantum.com>
 <20160816073246.GC5001@dhcp22.suse.cz> <20160816074316.GD5001@dhcp22.suse.cz>
 <6a22f206-e0e7-67c9-c067-73a55b6fbb41@Quantum.com>
 <a61f01eb-7077-07dd-665a-5125a1f8ef37@suse.cz>
 <0325d79b-186b-7d61-2759-686f8afff0e9@Quantum.com>
 <20160817093323.GB20703@dhcp22.suse.cz>
 <8008b7de-9728-a93c-e3d7-30d4ebeba65a@Quantum.com>
 <0606328a-1b14-0bc9-51cb-36621e3e8758@suse.cz>
 <e867d795-224f-5029-48c9-9ce515c0b75f@Quantum.com>
 <f050bc92-d2f1-80cc-f450-c5a57eaf82f0@suse.cz>
 <ea18e6b3-9d47-b154-5e12-face50578302@Quantum.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz>
Date: Fri, 19 Aug 2016 08:27:34 +0200
MIME-Version: 1.0
In-Reply-To: <ea18e6b3-9d47-b154-5e12-face50578302@Quantum.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/19/2016 04:42 AM, Ralf-Peter Rohbeck wrote:
> On 18.08.2016 13:12, Vlastimil Babka wrote:
>> On 18.8.2016 22:01, Ralf-Peter Rohbeck wrote:
>>> On 17.08.2016 23:57, Vlastimil Babka wrote:
>>>> Vlastimil
>>> Yes, that change was in my test with linux-next-20160817. Here's the diff:
>>>
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> index f94ae67..60a9ca2 100644
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -1083,8 +1083,10 @@ static void isolate_freepages(struct
>>> compact_control *cc)
>>>                           continue;
>>>
>>>                   /* Check the block is suitable for migration */
>>> +/*
>>>                   if (!suitable_migration_target(page))
>>>                           continue;
>>> +*/
>> OK, could you please also try if uncommenting the above still works without OOM?
>> Or just plain linux-next-20160817, I guess we don't need the printk's to test
>> this difference.
>>
>> Thanks a lot!
>> Vlastimil
>>
> With the two lines back in I had OOMs again. See the attached logs.

Thanks for the confirmation.

We however shouldn't disable the heuristic completely, so here's a compromise
patch hooking into the new compaction priorities. Can you please test on top of
linux-next?

-----8<-----
