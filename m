Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 514B66B004F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 13:40:58 -0400 (EDT)
Received: by gxk3 with SMTP id 3so1853333gxk.14
        for <linux-mm@kvack.org>; Thu, 23 Jul 2009 10:41:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A679FC5.6020206@zytor.com>
References: <alpine.DEB.1.00.0907201543230.22052@mail.selltech.ca>
	 <20090721154756.2AB7.A69D9226@jp.fujitsu.com>
	 <4A679FC5.6020206@zytor.com>
Date: Fri, 24 Jul 2009 02:41:00 +0900
Message-ID: <2f11576a0907231041x1841b8d4y554470b04e9ecc81@mail.gmail.com>
Subject: Re: Replacing 0x% with %# ?
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Li, Ming Chun" <macli@brc.ubc.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>> Hi MM list:
>>>
>>> I am newbie and wish to contribute tiny bit. Before I submit a trivial
>>> patch, I would ask if it is worth replacing =A0'0x%' with '%#' in print=
k in
>>> mm/*.c? If it is going to be noise for you guys, I would drop it and ke=
ep
>>> silent :).
>>
>> Never mind. we already post many trivial cleanup patches.
>>
>
> The other thing is that we reallly should make %p include the 0x prefix, =
as
> it does in userspace.

I think you mean %x, not %p. if so, I agree you. this difference
doesn't make any sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
