Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 84138600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 00:50:10 -0400 (EDT)
Received: by qyk9 with SMTP id 9so3381546qyk.14
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 21:50:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100727134431.2F11.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1007261510320.2993@chino.kir.corp.google.com>
	<AANLkTi=Aswf+Hp+qfsC2sCo32hU3E2D4zt3-R35BZ=MC@mail.gmail.com>
	<20100727134431.2F11.A69D9226@jp.fujitsu.com>
From: dave b <db.pub.mail@gmail.com>
Date: Tue, 27 Jul 2010 14:49:48 +1000
Message-ID: <AANLkTimdLbwvRNU09s+LfauREBaxyXBUE5jSmwnpCj8e@mail.gmail.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 27 July 2010 14:46, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>> On 27 July 2010 08:12, David Rientjes <rientjes@google.com> wrote:
>> > On Tue, 27 Jul 2010, dave b wrote:
>> >
>> >> Actually it turns out on 2.6.34.1 I can trigger this issue. What it
>> >> really is, is that linux doesn't invoke the oom killer when it should
>> >> and kill something off. This is *really* annoying.
>> >>
>> >
>> > I'm not exactly sure what you're referring to, it's been two months and
>> > you're using a new kernel and now you're saying that the oom killer isn't
>> > being utilized when the original problem statement was that it was killing
>> > things inappropriately?
>>
>> Sorry about the timespan :(
>> Well actually it is the same issue. Originally the oom killer wasn't
>> being invoked and now the problem is still it isn't invoked - it
>> doesn't come and kill things - my desktop just sits :)
>> I have since replaced the hard disk - which I thought could be the
>> issue. I am thinking that because I have shared graphics not using KMS
>> - with intel graphics - this may be the root of the cause.
>
> Do you mean the issue will be gone if disabling intel graphics?
> if so, we need intel graphics driver folks help. sorry, linux-mm folks don't
> know intel graphics detail.

Well the only other system I have running the 2.6.34.1 kernel atm is
an arm based system.
I originally sent this to the kernel list and was told I should
probably forward it to the mm list.
It may be a general issue or it could just be specific :)

--
"Not Hercules could have knock'd out his brains, for he had none."		--
Shakespeare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
