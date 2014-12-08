Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C395C6B0038
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 02:22:58 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so4650310pac.8
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 23:22:58 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id bg2si58823535pdb.20.2014.12.07.23.22.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Dec 2014 23:22:57 -0800 (PST)
Message-ID: <548551CC.70908@codeaurora.org>
Date: Mon, 08 Dec 2014 12:52:52 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: Questions about mm
References: <548527E3.6040104@gmail.com>
In-Reply-To: <548527E3.6040104@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sanidhya Kashyap <sanidhya.gatech@gmail.com>
Cc: linux-mm@kvack.org

Hi Sanidhya,

Could you explain your use-case or debug method ? Why do you need to 
keep a page even after its original process have got killed ?

thanks,

On 12/08/2014 09:54 AM, Sanidhya Kashyap wrote:
> Hello everyone,
>
> I have some questions about page allocation and locking.
>
> - Suppose that a process is about to be killed and before that happens, I want
> to keep the content of the page intact in the memory, i.e. the page should
> neither be zeored or allocated to some other process unless required. In order
> to achieve this, what can be the most optimal approach in which the internals of
> the kernel is not changed besides adding a syscall or something.
>
> - Another is what happens if I increase the count of mm_users and mm_count
> before and later that process gets killed. Assuming that the mm was linked only
> to the killed process. What will happen in this case?
>
> - Last question that I wanted to know is what will happen if I change the flags
> of the pages to be reserved and unevictable?
> Is it possible for the pages to be set pinned as well?
> Can this approach help me soling the first issue or I might get a BUG by some
> other component in kernel?
>
> Since, I have just started playing with the kernel, so there is a possibility
> that I might have asked something very silly/horrific. Please bear with me.
>
> Thanks,
> Sanidhya
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>


-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
