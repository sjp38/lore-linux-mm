Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 428936B0253
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 16:48:54 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e4so269997666pfg.4
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 13:48:54 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u123si4947104pgc.280.2017.01.28.13.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Jan 2017 13:48:53 -0800 (PST)
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
 <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
 <20170125231529.GA14993@devmasch>
 <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
 <20170128211119.GA68646@devmasch>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9779dfc7-5af6-666a-2cca-08f7ddd30e34@nvidia.com>
Date: Sat, 28 Jan 2017 13:48:46 -0800
MIME-Version: 1.0
In-Reply-To: <20170128211119.GA68646@devmasch>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ahmed Samy <f.fallen45@gmail.com>
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On 01/28/2017 01:11 PM, Ahmed Samy wrote:
> On Thu, Jan 26, 2017 at 12:33:02AM -0800, John Hubbard wrote:
>>
>> That's ioremap_page_range, I assume (rather than remap_page_range)?
>>
>> Overall, the remap_ram_range approach looks reasonable to me so far. I'll
>> look into the details tomorrow.
>>
>> I'm sure that most people on this list already know this, but...could you
>> say a few more words about how remapping system ram is used, why it's a good
>> thing and not a bad thing? :)
>>
>> thanks
>> john h
>>
> Please let me know if you're going to actually make a commit that either
> 	1) reverts that commit
> 	2) implements a "separate" function...

This email caught me as I was just sitting down to this. A couple days later than I expected, sorry.

>
> Either way, I don't think the un-export is reasonable in the slightest, if that
> function is too low-level, then why not also un-export pmd_offset(),
> pgd_offset(), perhaps current task too?  These interact directly with low-level
> stuff, not meant for drivers, the function is meant to be low-level, I don't know
> what made you think that people use it wrong?  How about writing proper
> documentation about it instead?

heh, I'm sure we're in strong agreement there: good documentation is desirable, yet sometimes 
missing. :) As for "what made you think that people use it wrong?", I think Zhong spotted a 
potential problem, then (if I understand correctly) decided that it was actually OK, but by then, I 
had egged him on to remove the EXPORT, because it looked "off" to me, too. (It still does.)

So I'll take the heat for this one, and that's why I'm following up on it.

   Besides, even if that function does not exist,
> you can always iterate the PTEs and set the physical address, it is not hard,
> but the safe way is via the kernel knowledge, which is what that function
> when combined with others (from vmalloc) provide...
>
> How about this, a function as part of vmalloc, that says something like
> `void *vremap(unsigned long phys, unsigned long size, unsigned long flags);`?
> Then that solved the problem and there is no need for "low level" functions,
> anymore.

Quick question, what do you mean "a function as part of vmalloc"?

>
> Other than, if you're not going to apply a proper workaround, then let me know,
> and I'll handle it myself from here.  I don't want this to get past the next
> -rc release, so please let's get this fixed...

Agreed.

thanks,
john h

>
> Thanks,
> 	asamy
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
