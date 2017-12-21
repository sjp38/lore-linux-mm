Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE2526B0069
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 05:19:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g8so15759249pgs.14
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 02:19:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id ay12sor7616424plb.110.2017.12.21.02.19.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 02:19:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201712201955.BHB30282.tMSFVFFJLQHOOO@I-love.SAKURA.ne.jp>
References: <94eb2c03c9bc75aff2055f70734c@google.com> <001a113f711a528a3f0560b08e76@google.com>
 <201712192327.FIJ64026.tMQFOOVFFLHOSJ@I-love.SAKURA.ne.jp>
 <CACT4Y+ZbE5=yeb=3hL8KDpPLarHJgihsTb6xX2+4fnoLFuBTow@mail.gmail.com>
 <CACT4Y+YZ6yuZqrjAxHEadW56TVS=x=WQqrfRrvMQ=LHU3+Kd8A@mail.gmail.com> <201712201955.BHB30282.tMSFVFFJLQHOOO@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 21 Dec 2017 11:19:06 +0100
Message-ID: <CACT4Y+Ybe4RFYdetcKV=YyXeDc6ePSMgd0gURXzoCz6k37Jeqw@mail.gmail.com>
Subject: Re: BUG: workqueue lockup (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>, syzkaller-bugs@googlegroups.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Dec 20, 2017 at 11:55 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> On Tue, Dec 19, 2017 at 3:27 PM, Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> > syzbot wrote:
>> >>
>> >> syzkaller has found reproducer for the following crash on
>> >> f3b5ad89de16f5d42e8ad36fbdf85f705c1ae051
>> >
>> > "BUG: workqueue lockup" is not a crash.
>>
>> Hi Tetsuo,
>>
>> What is the proper name for all of these collectively?
>
> I think that things which lead to kernel panic when /proc/sys/kernel/panic_on_oops
> was set to 1 are called an "oops" (or a "kerneloops").
>
> Speak of "BUG: workqueue lockup", this is not an "oops". This message was
> added by 82607adcf9cdf40f ("workqueue: implement lockup detector"), and
> this message does not always indicate a fatal problem. This message can be
> printed when the system is really out of CPU and memory. As far as I tested,
> I think that workqueue was not able to run on specific CPU due to a soft
> lockup bug.


There are also warnings which don't panic normally, unless
panic_on_warn is set. There are also cases when we suddenly lost a
machine and have no idea what happened with it. And also cases when we
are kind-a connected, and nothing bad is printed on console, but it's
still un-operable.
The only collective name I can think of is bug. We could change it to
bug. Otherwise since there are multiple names, I don't think it's
worth spending more time on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
