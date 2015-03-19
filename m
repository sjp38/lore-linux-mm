Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id C4B056B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 08:51:05 -0400 (EDT)
Received: by oiag65 with SMTP id g65so63620770oia.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 05:51:05 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id j195si672222oib.48.2015.03.19.05.51.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 05:51:04 -0700 (PDT)
Received: by oier21 with SMTP id r21so63694775oie.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 05:51:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0C41F6DA-DECD-48AD-90AD-DAF964950EB9@krogh.cc>
References: <52ec58f434865829c37337624d124981.squirrel@shrek.krogh.cc>
	<CABYiri81_RAtJizfpOdNPc6m9_Q2u0O35NX0ZhO1cxFpm866HQ@mail.gmail.com>
	<a0dcd8d7307e313474d4d721c76bb5a9.squirrel@shrek.krogh.cc>
	<CABYiri9BcgNEYD5C4qGf=3q6a=d549Rp9rXD7BAo8NkVDAPOqA@mail.gmail.com>
	<5509889C.2080602@suse.cz>
	<0C41F6DA-DECD-48AD-90AD-DAF964950EB9@krogh.cc>
Date: Thu, 19 Mar 2015 21:51:04 +0900
Message-ID: <CAAmzW4M=F_8x8qEAK2P-Pwg2hD28_Cy9+VVS-_VkQf79KuhSsw@mail.gmail.com>
Subject: Re: High system load and 3TB of memory.
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Krogh <jesper@krogh.cc>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrey Korolyov <andrey@xdel.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christian Marie <christian@ponies.io>

2015-03-19 0:14 GMT+09:00 Jesper Krogh <jesper@krogh.cc>:
>
>> On 18/03/2015, at 15.15, Vlastimil Babka <vbabka@suse.cz>
>> Right, it would be great if you could try it with 3.18+ kernel and possibly Joonsoo's patch from
>> http://marc.info/?l=linux-mm&m=141774145601066
>>
>
> Thanks, we will do that.
>
> We actually upgraded to 3.18.9 monday (together whith moving the database from postgresql 9.2 to 9.3) and we havent seen the problem since.
>
> Sysload is sitting around 8-10%
>
> But we will test

Hello,

It would be really nice if you could test my patch.
If possible, please test below patch rather than old one.
It solves some issues commented by Vlastimil and back ported to v3.18.

Thanks.

--------->8------------
