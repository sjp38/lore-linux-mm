Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CA369600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 04:09:46 -0400 (EDT)
Received: by qyk9 with SMTP id 9so3499329qyk.14
        for <linux-mm@kvack.org>; Tue, 27 Jul 2010 01:10:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100727150138.2F20.A69D9226@jp.fujitsu.com>
References: <20100727134431.2F11.A69D9226@jp.fujitsu.com> <AANLkTimdLbwvRNU09s+LfauREBaxyXBUE5jSmwnpCj8e@mail.gmail.com>
	<20100727150138.2F20.A69D9226@jp.fujitsu.com>
From: dave b <db.pub.mail@gmail.com>
Date: Tue, 27 Jul 2010 18:09:41 +1000
Message-ID: <AANLkTikjJ0giM+MpzNu3e0NQN=JLMviPT8UPHdZqGGpz@mail.gmail.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 27 July 2010 16:09, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Do you mean the issue will be gone if disabling intel graphics?
>> It may be a general issue or it could just be specific :)
>
> Hmm.. I'm puzzled 8-)
>
> I don't understand why other all people can't reproduce your issue
> even though your reproduce program is very simple.
>
> So, I'm guessing there is hidden reproduce condition. but I have no
> idea to find it.

I will try with the latest ubuntu and report how that goes (that will
be using fairly new xorg etc.) it is likely to be hidden issue just
with the intel graphics driver. However, my concern is that it isn't -
and it is about how shared graphics memory is handled :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
