Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 53FF26B0055
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 14:02:13 -0400 (EDT)
Message-ID: <4A68A562.9020109@zytor.com>
Date: Thu, 23 Jul 2009 11:01:06 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: Replacing 0x% with %# ?
References: <alpine.DEB.1.00.0907201543230.22052@mail.selltech.ca>	 <20090721154756.2AB7.A69D9226@jp.fujitsu.com>	 <4A679FC5.6020206@zytor.com> <2f11576a0907231041x1841b8d4y554470b04e9ecc81@mail.gmail.com>
In-Reply-To: <2f11576a0907231041x1841b8d4y554470b04e9ecc81@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Li, Ming Chun" <macli@brc.ubc.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>>>> Hi MM list:
>>>>
>>>> I am newbie and wish to contribute tiny bit. Before I submit a trivial
>>>> patch, I would ask if it is worth replacing  '0x%' with '%#' in printk in
>>>> mm/*.c? If it is going to be noise for you guys, I would drop it and keep
>>>> silent :).
>>> Never mind. we already post many trivial cleanup patches.
>>>
>> The other thing is that we reallly should make %p include the 0x prefix, as
>> it does in userspace.
> 
> I think you mean %x, not %p. if so, I agree you. this difference
> doesn't make any sense.

No, I mean %p.  %x should definitely not issue the 0x prefix without a # 
modifier.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
