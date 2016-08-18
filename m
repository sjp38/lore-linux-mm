Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7E1E83092
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 16:12:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so4603781wme.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 13:12:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d206si957127wmf.111.2016.08.18.13.12.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 13:12:11 -0700 (PDT)
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
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f050bc92-d2f1-80cc-f450-c5a57eaf82f0@suse.cz>
Date: Thu, 18 Aug 2016 22:12:13 +0200
MIME-Version: 1.0
In-Reply-To: <e867d795-224f-5029-48c9-9ce515c0b75f@Quantum.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 18.8.2016 22:01, Ralf-Peter Rohbeck wrote:
> On 17.08.2016 23:57, Vlastimil Babka wrote:
>>>>> Hmm. I added linux-next git, fetched it etc but apparently I didn't check
>>>>> out the right branch. Do you want next-20160817?
>>>> Yes this one should be OK. It contains Vlastimil's patches.
>>>>
>>>> Thanks!
>>> This has been working so far. I built a kernel successfully, with dd
>>> writing to two drives. There were a number of messages in the trace pipe
>>> but compaction/migration always succeeded it seems.
>>> I'll run the big torture test overnight.
>> Good news, thanks. Did you also apply Joonsoo's suggested removal of
>> suitable_migration_target() check, or is this just the linux-next
>> version with added trace_printk()/pr_info()?
>>
>> Vlastimil
> Yes, that change was in my test with linux-next-20160817. Here's the diff:
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f94ae67..60a9ca2 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1083,8 +1083,10 @@ static void isolate_freepages(struct 
> compact_control *cc)
>                          continue;
> 
>                  /* Check the block is suitable for migration */
> +/*
>                  if (!suitable_migration_target(page))
>                          continue;
> +*/

OK, could you please also try if uncommenting the above still works without OOM?
Or just plain linux-next-20160817, I guess we don't need the printk's to test
this difference.

Thanks a lot!
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
