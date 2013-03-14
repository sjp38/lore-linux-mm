Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id F3BAB6B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 19:10:41 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hq4so127wib.0
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 16:10:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51424000.1030309@gmx.de>
References: <51422008.3020208@gmx.de>
	<CAFLxGvyzkSsUJQMefeB2PcVBykZNqCQe5k19k0MqyVr111848w@mail.gmail.com>
	<514239F7.3050704@gmx.de>
	<20130314212107.GA23056@redhat.com>
	<51424000.1030309@gmx.de>
Date: Fri, 15 Mar 2013 00:10:40 +0100
Message-ID: <CAFLxGvzcy_+2exNbbCGZ460Y417MjoChY39FPXvqaEOZTq8ofQ@mail.gmail.com>
Subject: Re: SLUB + UML : WARNING: at mm/page_alloc.c:2386
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, user-mode-linux-user@lists.sourceforge.net, Linux Kernel <linux-kernel@vger.kernel.org>, Davi Arnaut <davi.arnaut@gmail.com>

On Thu, Mar 14, 2013 at 10:24 PM, Toralf F=F6rster <toralf.foerster@gmx.de>=
 wrote:
> On 03/14/2013 10:21 PM, Dave Jones wrote:
>> hah, strndup_user taking a signed long instead of a size_t as it's lengt=
h arg.
>>
>> either it needs to change, or it needs an explicit check for < 1
>>
>> I wonder how many other paths make it possible to pass negative numbers =
here.
>
> just for the statistics - currently -14 rules  :
>
> 2013-03-14T22:06:21.618+01:00 trinity kernel: memdup_user: -14
> 2013-03-14T22:06:25.664+01:00 trinity kernel: memdup_user: 28
> 2013-03-14T22:06:25.664+01:00 trinity kernel: memdup_user: -14
> 2013-03-14T22:06:37.533+01:00 trinity kernel: memdup_user: 3
> 2013-03-14T22:08:03.379+01:00 trinity kernel: memdup_user: -14
> 2013-03-14T22:09:34.668+01:00 trinity kernel: memdup_user: -14
> 2013-03-14T22:12:33.277+01:00 trinity kernel: memdup_user: -14
> 2013-03-14T22:13:15.214+01:00 trinity kernel: memdup_user: 2
> 2013-03-14T22:14:18.874+01:00 trinity kernel: trinity-watchdo[1169]: segf=
ault at 244 ip 0804c956 sp bf836c9c error 4 in trinity[8048000+1d000]
> 2013-03-14T22:15:10.287+01:00 trinity kernel: memdup_user: 2
> 2013-03-14T22:15:10.287+01:00 trinity kernel: memdup_user: 2
> 2013-03-14T22:17:50.351+01:00 trinity kernel: memdup_user: 2
> 2013-03-14T22:17:59.411+01:00 trinity kernel: memdup_user: -14
>

-14 is -EFAULT.
Time to look at UML's __get_user().

--=20
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
