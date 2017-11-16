Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48CAD280259
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 02:36:06 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 70so15319596pgf.5
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 23:36:06 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id d132si434381pgc.27.2017.11.15.23.36.04
        for <linux-mm@kvack.org>;
        Wed, 15 Nov 2017 23:36:05 -0800 (PST)
Subject: Re: [PATCH] locking/Documentation: Revise
 Documentation/locking/crossrelease.txt
References: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
 <1510407214-31452-1-git-send-email-byungchul.park@lge.com>
 <20171111134524.GA16714@X58A-UD3R> <20171116000456.GB4394@X58A-UD3R>
 <20171116072237.jcztqvlnzerzyozh@gmail.com>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <57849b74-b825-b4b2-7863-c22998b86291@lge.com>
Date: Thu, 16 Nov 2017 16:36:02 +0900
MIME-Version: 1.0
In-Reply-To: <20171116072237.jcztqvlnzerzyozh@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

On 11/16/2017 4:22 PM, Ingo Molnar wrote:
> 
> * Byungchul Park <byungchul.park@lge.com> wrote:
> 
>> On Sat, Nov 11, 2017 at 10:45:24PM +0900, Byungchul Park wrote:
>>> This is the big one including all of version 3.
>>>
>>> You can take only this.
>>
>> Hello Ingo,
>>
>> Could you consider this?
> 
> Yeah, I'll have a look in a few days, but right now we are in the middle of the
> merge window.

Thank you very much.

> 
> Thanks,
> 
> 	Ingo
> 

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
