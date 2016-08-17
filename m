Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D92156B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 19:37:25 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i140so5566060qke.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 16:37:25 -0700 (PDT)
Received: from mx04-000ceb01.pphosted.com (mx0b-000ceb01.pphosted.com. [67.231.152.126])
        by mx.google.com with ESMTPS id t81si580754wmf.1.2016.08.17.16.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 16:37:25 -0700 (PDT)
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
From: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Message-ID: <8008b7de-9728-a93c-e3d7-30d4ebeba65a@Quantum.com>
Date: Wed, 17 Aug 2016 16:37:19 -0700
MIME-Version: 1.0
In-Reply-To: <20160817093323.GB20703@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 17.08.2016 02:33, Michal Hocko wrote:
> On Wed 17-08-16 02:28:35, Ralf-Peter Rohbeck wrote:
>> On 17.08.2016 02:23, Vlastimil Babka wrote:
> [...]
>>> 4.8.0-rc2 is not "linux-next". What Michal meant is the linux-next git
>>> (there's no tarball on kernel.org for it):
>>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
>> Hmm. I added linux-next git, fetched it etc but apparently I didn't check
>> out the right branch. Do you want next-20160817?
> Yes this one should be OK. It contains Vlastimil's patches.
>
> Thanks!

This has been working so far. I built a kernel successfully, with dd 
writing to two drives. There were a number of messages in the trace pipe 
but compaction/migration always succeeded it seems.
I'll run the big torture test overnight.

Ralf-Peter

----------------------------------------------------------------------
The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
