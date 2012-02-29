Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 6BE946B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 08:44:11 -0500 (EST)
Received: by bkwq16 with SMTP id q16so435474bkw.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 05:44:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.wafz3gv53l0zgt@mpn-glaptop>
References: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com>
 <CAGsJ_4wgVcVjtAa6Qpki=8jSON7MfwJ8yumJ1YXE5p8L3PqUzw@mail.gmail.com>
 <op.wafuu3kr3l0zgt@mpn-glaptop> <CAGsJ_4yk+Ca4RDP=sYaXvEKuJzYNhyZWQ7jfKnpR+zCm=3Dq6Q@mail.gmail.com>
 <op.wafz3gv53l0zgt@mpn-glaptop>
From: Barry Song <21cnbao@gmail.com>
Date: Wed, 29 Feb 2012 21:43:49 +0800
Message-ID: <CAGsJ_4zYttky4+FbzmmaPzQ4b3HwjnpwhX_vE7My9J=ytm20RA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv23 00/16] Contiguous Memory Allocator
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, DL-SHA-WorkGroupLinux <workgroup.linux@csr.com>

2012/2/29 Michal Nazarewicz <mina86@mina86.com>:
> On Wed, 29 Feb 2012 14:34:02 +0100, Barry Song <21cnbao@gmail.com> wrote:
>
>> 2012/2/29 Michal Nazarewicz <mina86@mina86.com>:
>>>
>>> On Wed, 29 Feb 2012 10:35:42 +0100, Barry Song <21cnbao@gmail.com> wrot=
e:
>>>>
>>>> and i also write a simple kernel helper to test the CMA:
>
>
>>> Would it make sense to make a patch out of it putting it to tools/cma (=
or
>>> similar)?
>
>
>> i can send a patch for this. i am just thinking, should it be placed
>> in tools/ as a test utility or Documents/ as an example to explain CMA
>> to users who want to use cma.
>
>
> I'd put it in tools/.

ok. i will handle this.

>
>
>> i also think we should have a seperate document to explain cma in detail=
s
>> in documents/, and my helper program can be placed there.
>
>
> I'm currently writing an article for LWN which I hope will also lead to
> something
> worth putting in Documentation/.
>

fine.

>
> --
> Best regards, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 _ =C2=A0 =C2=A0 _
> .o. | Liege of Serenely Enlightened Majesty of =C2=A0 =C2=A0 =C2=A0o' \,=
=3D./ `o
> ..o | Computer Science, =C2=A0Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazare=
wicz =C2=A0 =C2=A0(o o)
> ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

-barry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
