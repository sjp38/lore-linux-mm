Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A838F6B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 12:50:40 -0500 (EST)
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
References: <4B71927D.6030607@nortel.com>
	<20100210093140.12D9.A69D9226@jp.fujitsu.com>
	<4B72E74C.9040001@nortel.com>
	<28c262361002101645g3fd08cc7t6a72d27b1f94db62@mail.gmail.com>
	<4B74524D.8080804@nortel.com>
	<28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Fri, 12 Feb 2010 17:50:31 +0000
In-Reply-To: <28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com> (Minchan Kim's message of "Fri\, 12 Feb 2010 11\:38\:12 +0900")
Message-ID: <tnxk4ui9wd4.fsf@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Chris Friesen <cfriesen@nortel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Minchan Kim <minchan.kim@gmail.com> wrote:
> On Fri, Feb 12, 2010 at 3:54 AM, Chris Friesen <cfriesen@nortel.com> wrot=
e:
>> I have a modified version of that which I picked up as part of the
>> kmemleak backport. =C2=A0However, it doesn't help unless I can narrow do=
wn
>> *which* pages I should care about.
>
> kmemleak doesn't support page allocator and ioremap.
> Above URL patch just can tell who requests page which is using(ie, not
> free) now.

The ioremap can be easily tracked by kmemleak (it is on my to-do list
but haven't managed to do it yet). That's not far from vmalloc.

The page allocator is a bit more difficult since it's used by the slab
allocator as well and it may lead to some recursive calls into
kmemleak. I'll have a think.

Anyway, you can leak memory without this being detected by kmemleak -
just add the allocated objects to a list and never remove them.

--=20
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
