Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 8385A6B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 17:24:20 -0400 (EDT)
Received: from mailout-de.gmx.net ([10.1.76.4]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0Lvegk-1UoU1P0QIu-017WHQ for
 <linux-mm@kvack.org>; Thu, 14 Mar 2013 22:24:19 +0100
Message-ID: <51424000.1030309@gmx.de>
Date: Thu, 14 Mar 2013 22:24:16 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: SLUB + UML : WARNING: at mm/page_alloc.c:2386
References: <51422008.3020208@gmx.de> <CAFLxGvyzkSsUJQMefeB2PcVBykZNqCQe5k19k0MqyVr111848w@mail.gmail.com> <514239F7.3050704@gmx.de> <20130314212107.GA23056@redhat.com>
In-Reply-To: <20130314212107.GA23056@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, richard -rw- weinberger <richard.weinberger@gmail.com>, linux-mm@kvack.org, user-mode-linux-user@lists.sourceforge.net, Linux Kernel <linux-kernel@vger.kernel.org>, Davi Arnaut <davi.arnaut@gmail.com>

On 03/14/2013 10:21 PM, Dave Jones wrote:
> hah, strndup_user taking a signed long instead of a size_t as it's length arg.
> 
> either it needs to change, or it needs an explicit check for < 1
> 
> I wonder how many other paths make it possible to pass negative numbers here.

just for the statistics - currently -14 rules  :

2013-03-14T22:06:21.618+01:00 trinity kernel: memdup_user: -14
2013-03-14T22:06:25.664+01:00 trinity kernel: memdup_user: 28
2013-03-14T22:06:25.664+01:00 trinity kernel: memdup_user: -14
2013-03-14T22:06:37.533+01:00 trinity kernel: memdup_user: 3
2013-03-14T22:08:03.379+01:00 trinity kernel: memdup_user: -14
2013-03-14T22:09:34.668+01:00 trinity kernel: memdup_user: -14
2013-03-14T22:12:33.277+01:00 trinity kernel: memdup_user: -14
2013-03-14T22:13:15.214+01:00 trinity kernel: memdup_user: 2
2013-03-14T22:14:18.874+01:00 trinity kernel: trinity-watchdo[1169]: segfault at 244 ip 0804c956 sp bf836c9c error 4 in trinity[8048000+1d000]
2013-03-14T22:15:10.287+01:00 trinity kernel: memdup_user: 2
2013-03-14T22:15:10.287+01:00 trinity kernel: memdup_user: 2
2013-03-14T22:17:50.351+01:00 trinity kernel: memdup_user: 2
2013-03-14T22:17:59.411+01:00 trinity kernel: memdup_user: -14

:-D

-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
