Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2576B0267
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:57:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so9636790wml.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 23:57:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w6si28752151wmw.38.2016.08.17.23.57.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Aug 2016 23:57:14 -0700 (PDT)
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
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0606328a-1b14-0bc9-51cb-36621e3e8758@suse.cz>
Date: Thu, 18 Aug 2016 08:57:12 +0200
MIME-Version: 1.0
In-Reply-To: <8008b7de-9728-a93c-e3d7-30d4ebeba65a@Quantum.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/18/2016 01:37 AM, Ralf-Peter Rohbeck wrote:
> On 17.08.2016 02:33, Michal Hocko wrote:
>> On Wed 17-08-16 02:28:35, Ralf-Peter Rohbeck wrote:
>>> On 17.08.2016 02:23, Vlastimil Babka wrote:
>> [...]
>>>> 4.8.0-rc2 is not "linux-next". What Michal meant is the linux-next git
>>>> (there's no tarball on kernel.org for it):
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
>>> Hmm. I added linux-next git, fetched it etc but apparently I didn't check
>>> out the right branch. Do you want next-20160817?
>> Yes this one should be OK. It contains Vlastimil's patches.
>>
>> Thanks!
>
> This has been working so far. I built a kernel successfully, with dd
> writing to two drives. There were a number of messages in the trace pipe
> but compaction/migration always succeeded it seems.
> I'll run the big torture test overnight.

Good news, thanks. Did you also apply Joonsoo's suggested removal of 
suitable_migration_target() check, or is this just the linux-next 
version with added trace_printk()/pr_info()?

Vlastimil

> Ralf-Peter
>
> ----------------------------------------------------------------------
> The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
