Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97E1D8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:32:54 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id w4so9426911otj.2
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:32:54 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r6si3704808oia.253.2019.01.22.02.32.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 02:32:53 -0800 (PST)
Subject: Re: possible deadlock in __do_page_fault
References: <000000000000f7a28e057653dc6e@google.com>
 <20180920141058.4ed467594761e073606eafe2@linux-foundation.org>
 <CAHRSSEzX5HOUEQ6DgEF76OLGrwS1isWMdtvneBLOEEnwoMxVrA@mail.gmail.com>
 <CAEXW_YSot+3AMQ=jmDRowmqoOmQmujp9r8Dh18KJJN1EDmyHOw@mail.gmail.com>
 <20180921162110.e22d09a9e281d194db3c8359@linux-foundation.org>
 <4b0a5f8c-2be2-db38-a70d-8d497cb67665@I-love.SAKURA.ne.jp>
 <CACT4Y+ZTjCGd9XYUCUoqv+AqXrPwX4OqWMC0jFgjNxZRFkNYXw@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <c56d4d0b-8ecc-059d-69cb-4f3e91f9410c@i-love.sakura.ne.jp>
Date: Tue, 22 Jan 2019 19:32:34 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZTjCGd9XYUCUoqv+AqXrPwX4OqWMC0jFgjNxZRFkNYXw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joel@joelfernandes.org>, Todd Kjos <tkjos@google.com>, Joel Fernandes <joelaf@google.com>, syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com, Andi Kleen <ak@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Souptick Joarder <jrdr.linux@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@techsingularity.net>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 2019/01/22 19:12, Dmitry Vyukov wrote:
> On Tue, Jan 22, 2019 at 11:02 AM Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>
>> On 2018/09/22 8:21, Andrew Morton wrote:
>>> On Thu, 20 Sep 2018 19:33:15 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:
>>>
>>>> On Thu, Sep 20, 2018 at 5:12 PM Todd Kjos <tkjos@google.com> wrote:
>>>>>
>>>>> +Joel Fernandes
>>>>>
>>>>> On Thu, Sep 20, 2018 at 2:11 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>>>>>>
>>>>>>
>>>>>> Thanks.  Let's cc the ashmem folks.
>>>>>>
>>>>
>>>> This should be fixed by https://patchwork.kernel.org/patch/10572477/
>>>>
>>>> It has Neil Brown's Reviewed-by but looks like didn't yet appear in
>>>> anyone's tree, could Greg take this patch?
>>>
>>> All is well.  That went into mainline yesterday, with a cc:stable.
>>>
>>
>> This problem was not fixed at all.
> 
> There are at least 2 other open deadlocks involving ashmem:

Yes, they involve ashmem_shrink_scan() => {shmem|vfs}_fallocate() sequence.
This approach tries to eliminate this sequence.

> 
> https://syzkaller.appspot.com/bug?extid=148c2885d71194f18d28
> https://syzkaller.appspot.com/bug?extid=4b8b031b89e6b96c4b2e
> 
> Does this fix any of these too?

I need checks from ashmem folks whether this approach is possible/correct.
But you can ask syzbot to test this patch before ashmem folks respond.
