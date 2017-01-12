Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E95196B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 06:10:03 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id iq1so3111353wjb.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 03:10:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d21si7014084wrc.113.2017.01.12.03.10.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 03:10:02 -0800 (PST)
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
 <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
 <CAFpQJXWD8pSaWUrkn5Rxy-hjTCvrczuf0F3TdZ8VHj4DSYpivg@mail.gmail.com>
 <20170111164616.GJ16365@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <45ed555a-c6a3-fc8e-1e87-c347c8ed086b@suse.cz>
Date: Thu, 12 Jan 2017 12:10:00 +0100
MIME-Version: 1.0
In-Reply-To: <20170111164616.GJ16365@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 01/11/2017 05:46 PM, Michal Hocko wrote:
> On Wed 11-01-17 21:52:29, Ganapatrao Kulkarni wrote:
>
>> [ 2398.169391] Node 1 Normal: 951*4kB (UME) 1308*8kB (UME) 1034*16kB (UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME) 275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) = 12047196kB
>
> Most of the memblocks are marked Unmovable (except for the 4MB bloks)

No, UME here means that e.g. 4kB blocks are available on unmovable, movable and 
reclaimable lists.

> which shouldn't matter because we can fallback to unmovable blocks for
> movable allocation AFAIR so we shouldn't really fail the request. I
> really fail to see what is going on there but it smells really
> suspicious.

Perhaps there's something wrong with zonelists and we are skipping the Node 1 
Normal zone. Or there's some race with cpuset operations (but can't see how).

The question is, how reproducible is this? And what exactly the test cpuset01 
does? Is it doing multiple things in a loop that could be reduced to a single 
testcase?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
