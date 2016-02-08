Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 83F91828E2
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 18:15:15 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id ho8so80862428pac.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 15:15:15 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id d89si49457209pfj.146.2016.02.08.15.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 15:15:14 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id e127so21586447pfe.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 15:15:14 -0800 (PST)
Subject: Re: [RFC V5] Add gup trace points support
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
 <56955B76.2060503@linaro.org> <20160112151052.168bba85@gandalf.local.home>
 <56969400.6020805@linaro.org> <20160114094007.5b5c6e4d@gandalf.local.home>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <56B92176.7030609@linaro.org>
Date: Mon, 8 Feb 2016 15:15:02 -0800
MIME-Version: 1.0
In-Reply-To: <20160114094007.5b5c6e4d@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org
Cc: mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

Hi Andrew,

This series already got acked from Steven and arch maintainers except 
for x86. How should I proceed? Any comment is appreciated.

Thanks,
Yang


On 1/14/2016 6:40 AM, Steven Rostedt wrote:
>
> Andrew,
>
> Do you want to pull in this series? You can add my Acked-by to the whole
> set.
>
> -- Steve
>
>
> On Wed, 13 Jan 2016 10:14:24 -0800
> "Shi, Yang" <yang.shi@linaro.org> wrote:
>
>> On 1/12/2016 12:10 PM, Steven Rostedt wrote:
>>> On Tue, 12 Jan 2016 12:00:54 -0800
>>> "Shi, Yang" <yang.shi@linaro.org> wrote:
>>>
>>>> Hi Steven,
>>>>
>>>> Any more comments on this series? How should I proceed it?
>>>>
>>>
>>> The tracing part looks fine to me. Now you just need to get the arch
>>> maintainers to ack each of the arch patches, and I can pull them in for
>>> 4.6. Too late for 4.5. Probably need Andrew Morton's ack for the
>>> mm/gup.c patch.
>>
>> Thanks Steven. Already sent email to x86, s390 and sparc maintainers.
>> Ralf already acked the MIPS part since v1.
>>
>> Regards,
>> Yang
>>
>>>
>>> -- Steve
>>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
