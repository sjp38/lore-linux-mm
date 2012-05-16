Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 0FD0F6B00EA
	for <linux-mm@kvack.org>; Wed, 16 May 2012 07:06:20 -0400 (EDT)
Received: by wefh52 with SMTP id h52so555993wef.14
        for <linux-mm@kvack.org>; Wed, 16 May 2012 04:06:18 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <4FB3048C.20008@kernel.org>
References: <4FAB21E7.7020703@kernel.org>
	<20120510140215.GC26152@phenom.dumpdata.com>
	<4FABD503.4030808@vflare.org>
	<4FABDA9F.1000105@linux.vnet.ibm.com>
	<20120510151941.GA18302@kroah.com>
	<4FABECF5.8040602@vflare.org>
	<20120510164418.GC13964@kroah.com>
	<4FABF9D4.8080303@vflare.org>
	<20120510173322.GA30481@phenom.dumpdata.com>
	<4FAC4E3B.3030909@kernel.org>
	<20120511192831.GC3785@phenom.dumpdata.com>
	<4FB06B91.1080008@kernel.org>
	<CAPbh3ruv9xCV_XpR4ZsZpSGQ8=mibg=a39zvADYETb-tg0kBsA@mail.gmail.com>
	<4FB3048C.20008@kernel.org>
Date: Wed, 16 May 2012 07:06:18 -0400
Message-ID: <CAPbh3ruFRLzGn88G1=BajKS1VAw7hQDPNMH9yUO5JB0UDVF5Mg@mail.gmail.com>
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>>> It's not good abstraction.
>>
>> If we want good abstraction, then I don't think 'unsigned long' is
>> either? I mean it will do for the conversion from 'void *'. Perhaps I
>> am being a bit optimistic here - and I am trying to jam in this
>> 'struct zs_handle' in all cases but in reality it needs a more
>> iterative process. So first do 'void *' -> 'unsigned long', and then
>> later on if we can come up with something more nicely that abstracts
>> - then use that?

..snip..
>>> No. What I want is to remove coupling zsallocator's handle with zram/zc=
ache.
>>> They shouldn't know internal of handle and assume it's a pointer.
>>
>> I concur. And hence I was thinking that the 'struct zs_handle *'
>> pointer would work.
>
>
> Do you really hate "unsigned long" as handle?
..snip,,
>> Well, everything changes over time =A0so putting a stick in the ground
>> and saying 'this must
>> be this way' is not really the best way.
>
>
> Hmm, agree on your above statement but I can't imagine better idea.
>

OK. Lets go with unsigned long. I can prep a patch next week when I am
back from vacation unless somebody beats me to it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
