Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id F237C28089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 11:24:55 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id 78so74312762vkj.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 08:24:55 -0800 (PST)
Received: from mail-ua0-x22c.google.com (mail-ua0-x22c.google.com. [2607:f8b0:400c:c08::22c])
        by mx.google.com with ESMTPS id q9si2417221uab.248.2017.02.08.08.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 08:24:54 -0800 (PST)
Received: by mail-ua0-x22c.google.com with SMTP id 35so113121287uak.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 08:24:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1FEF704E-915D-4A2B-987A-593B8EABE961@gmail.com>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <1FEF704E-915D-4A2B-987A-593B8EABE961@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 8 Feb 2017 08:24:33 -0800
Message-ID: <CALCETrX251wcdd88drUnAb4yTqAoufkFRH1br4ZuDfp0nxYRKw@mail.gmail.com>
Subject: Re: PCID review?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Feb 7, 2017 at 11:37 AM, Nadav Amit <nadav.amit@gmail.com> wrote:
> Just a small question: should try_to_unmap_flush() work with these changes?

Ugh, I probably need to fix that up.  Thanks!

>
>> On Feb 7, 2017, at 10:56 AM, Andy Lutomirski <luto@kernel.org> wrote:
>>
>> Quite a few people have expressed interest in enabling PCID on (x86)
>> Linux.  Here's the code:
>>
>> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid
>>
>> The main hold-up is that the code needs to be reviewed very carefully.
>> It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
>> entries using PCID" ought to be looked at carefully to make sure the
>> locking is right, but there are plenty of other ways this this could
>> all break.
>>
>> Anyone want to take a look or maybe scare up some other reviewers?
>> (Kees, you seemed *really* excited about getting this in.)
>>
>> --Andy
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
