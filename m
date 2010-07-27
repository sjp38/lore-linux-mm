Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0ECE260080D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 07:26:37 -0400 (EDT)
Received: by pvc30 with SMTP id 30so473568pvc.14
        for <linux-mm@kvack.org>; Tue, 27 Jul 2010 04:26:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100727200804.2F40.A69D9226@jp.fujitsu.com>
References: <AANLkTikjJ0giM+MpzNu3e0NQN=JLMviPT8UPHdZqGGpz@mail.gmail.com>
	<AANLkTinT_W4Zfg8xcpKXMpqTAomdVBdHve7VqamdSr4o@mail.gmail.com>
	<20100727200804.2F40.A69D9226@jp.fujitsu.com>
From: dave b <db.pub.mail@gmail.com>
Date: Tue, 27 Jul 2010 21:26:16 +1000
Message-ID: <AANLkTin47_htYK8eV-6C4QkRK_U__qYeWX16Ly=YK-0w@mail.gmail.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 27 July 2010 21:14, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>> On 27 July 2010 18:09, dave b <db.pub.mail@gmail.com> wrote:
>> > On 27 July 2010 16:09, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >>> > Do you mean the issue will be gone if disabling intel graphics?
>> >>> It may be a general issue or it could just be specific :)
>> >
>> > I will try with the latest ubuntu and report how that goes (that will
>> > be using fairly new xorg etc.) it is likely to be hidden issue just
>> > with the intel graphics driver. However, my concern is that it isn't -
>> > and it is about how shared graphics memory is handled :)
>>
>>
>> Ok my desktop still stalled and no oom killer was invoked when I added
>> swap to a live-cd of 10.04 amd64.
>>
>> *Without* *swap* *on* - the oom killer was invoked - here is a copy of it.
>
> This stack seems similar following bug. can you please try to disable intel graphics
> driver?
>
> https://bugzilla.kernel.org/show_bug.cgi?id=14933

Ok I am not sure how to do that :)
I could revert the patch and see if it 'fixes' this :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
