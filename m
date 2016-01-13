Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE42828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 13:14:26 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id uo6so346213048pac.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:14:26 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id wb3si3374358pab.114.2016.01.13.10.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 10:14:25 -0800 (PST)
Received: by mail-pa0-x230.google.com with SMTP id yy13so269495121pab.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:14:25 -0800 (PST)
Subject: Re: [RFC V5] Add gup trace points support
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
 <56955B76.2060503@linaro.org> <20160112151052.168bba85@gandalf.local.home>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <56969400.6020805@linaro.org>
Date: Wed, 13 Jan 2016 10:14:24 -0800
MIME-Version: 1.0
In-Reply-To: <20160112151052.168bba85@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 1/12/2016 12:10 PM, Steven Rostedt wrote:
> On Tue, 12 Jan 2016 12:00:54 -0800
> "Shi, Yang" <yang.shi@linaro.org> wrote:
>
>> Hi Steven,
>>
>> Any more comments on this series? How should I proceed it?
>>
>
> The tracing part looks fine to me. Now you just need to get the arch
> maintainers to ack each of the arch patches, and I can pull them in for
> 4.6. Too late for 4.5. Probably need Andrew Morton's ack for the
> mm/gup.c patch.

Thanks Steven. Already sent email to x86, s390 and sparc maintainers. 
Ralf already acked the MIPS part since v1.

Regards,
Yang

>
> -- Steve
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
