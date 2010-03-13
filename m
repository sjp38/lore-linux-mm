Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 346626B00D6
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 18:44:59 -0500 (EST)
Received: by iwn11 with SMTP id 11so2126991iwn.11
        for <linux-mm@kvack.org>; Sat, 13 Mar 2010 15:44:57 -0800 (PST)
Message-ID: <4B9C2376.9040309@gmail.com>
Date: Sat, 13 Mar 2010 17:44:54 -0600
From: Robert Hancock <hancockrwd@gmail.com>
MIME-Version: 1.0
Subject: Re: Linux kernel - Libata bad block error handling to user mode
 program
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>	 <4B8FC6AC.4060801@teksavvy.com>	 <87f94c371003111029s7c7daebgf691ab11e6bdda25@mail.gmail.com> <f875e2fe1003131444p238ad546xdadb3fca530fb074@mail.gmail.com>
In-Reply-To: <f875e2fe1003131444p238ad546xdadb3fca530fb074@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: s ponnusa <foosaa@gmail.com>
Cc: Greg Freemyer <greg.freemyer@gmail.com>, Mark Lord <kernel@teksavvy.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/13/2010 04:44 PM, s ponnusa wrote:
> Had some issues with the libata in 2.6.27 kernel's libata code, but
> believe the issues were fixed in the subsequent versions. Atleast one
> prominent issue was with a Western Digital HDD of 40 GB size. The
> manufacturer specific LBA was 78125000 and was reported as correctly
> in Win32 and DOS applications. But the 2.6.27 kernel was reporting
> ~40000 sectors more. But the problem dissappeared with the 2.6.3x
> kernel and I did not bother to check the patches due to lack of time.
> But still, the write's failure is not being seen by the application. I
> can understand the fact of not checking the media errors during the
> write operation, and had posted a request for a quick suggestions of
> the locations which needs to be changed / checked for the return
> value. ( Should it be handled at the vfs or at the libata code?). Will
> surely update the testing results with the new kernel (Well, not
> exactly as I am not using the latest version though! Currently trying
> with 2.6.31). Thank you all for suggestions.

It's quite likely for write errors not to be noticed by the application. 
Even if the drive does report a write error, the application that wrote 
the data could have completed the write and even closed the file or 
exited before the data actually gets written to disk. Only if fsync (or 
related functions) are called on the file is it guaranteed that the data 
has been written out to the drive (and any generated errors should be 
seen at that time).

> -
> SP
>
> On Thu, Mar 11, 2010 at 1:29 PM, Greg Freemyer<greg.freemyer@gmail.com>  wrote:
>>>
>>> But really.. isn't "hdparm --security-erase NULL /dev/sdX" good enough ???
>>>
>>
>> This thread seems to have died off.  If there is a real problem, I
>> hope it picks back up.
>>
>> Mark, as to your question the few times I've tried that the bios on
>> the test machine blocked the command.  So it may have some specific
>> utility, but it's a not a generic solution in my mind.
>>
>> Greg
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ide" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
