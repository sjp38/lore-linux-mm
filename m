Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0AEF6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:35:46 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id a194so17457724oib.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 20:35:46 -0800 (PST)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id w35si4480250otb.160.2017.01.12.20.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 20:35:45 -0800 (PST)
Received: by mail-oi0-x244.google.com with SMTP id u143so5519909oif.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 20:35:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <45ed555a-c6a3-fc8e-1e87-c347c8ed086b@suse.cz>
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz> <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
 <CAFpQJXWD8pSaWUrkn5Rxy-hjTCvrczuf0F3TdZ8VHj4DSYpivg@mail.gmail.com>
 <20170111164616.GJ16365@dhcp22.suse.cz> <45ed555a-c6a3-fc8e-1e87-c347c8ed086b@suse.cz>
From: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Date: Fri, 13 Jan 2017 10:05:45 +0530
Message-ID: <CAFpQJXUVRKXLUvM5PnpjT_UH+ac-0=caND43F882oP+Rm5gxUQ@mail.gmail.com>
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jan 12, 2017 at 4:40 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 01/11/2017 05:46 PM, Michal Hocko wrote:
>>
>> On Wed 11-01-17 21:52:29, Ganapatrao Kulkarni wrote:
>>
>>> [ 2398.169391] Node 1 Normal: 951*4kB (UME) 1308*8kB (UME) 1034*16kB
>>> (UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME)
>>> 275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) = 12047196kB
>>
>>
>> Most of the memblocks are marked Unmovable (except for the 4MB bloks)
>
>
> No, UME here means that e.g. 4kB blocks are available on unmovable, movable
> and reclaimable lists.
>
>> which shouldn't matter because we can fallback to unmovable blocks for
>> movable allocation AFAIR so we shouldn't really fail the request. I
>> really fail to see what is going on there but it smells really
>> suspicious.
>
>
> Perhaps there's something wrong with zonelists and we are skipping the Node
> 1 Normal zone. Or there's some race with cpuset operations (but can't see
> how).
>
> The question is, how reproducible is this? And what exactly the test
> cpuset01 does? Is it doing multiple things in a loop that could be reduced
> to a single testcase?

IIUC, this test does node change to  cpuset.mems in loop in parent
process in loop and child processes(equal to no of cpus) keeps on
allocation and freeing
10 pages till the execution time is over.
more details at
https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/cpuset/cpuset01.c

thanks
Ganapat

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
