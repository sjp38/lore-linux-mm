Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 15FDD6B004D
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 08:34:24 -0500 (EST)
Received: by bkwq16 with SMTP id q16so420420bkw.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 05:34:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.wafuu3kr3l0zgt@mpn-glaptop>
References: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com>
 <CAGsJ_4wgVcVjtAa6Qpki=8jSON7MfwJ8yumJ1YXE5p8L3PqUzw@mail.gmail.com> <op.wafuu3kr3l0zgt@mpn-glaptop>
From: Barry Song <21cnbao@gmail.com>
Date: Wed, 29 Feb 2012 21:34:02 +0800
Message-ID: <CAGsJ_4yk+Ca4RDP=sYaXvEKuJzYNhyZWQ7jfKnpR+zCm=3Dq6Q@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv23 00/16] Contiguous Memory Allocator
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, DL-SHA-WorkGroupLinux <workgroup.linux@csr.com>

Michal,

2012/2/29 Michal Nazarewicz <mina86@mina86.com>:
> On Wed, 29 Feb 2012 10:35:42 +0100, Barry Song <21cnbao@gmail.com> wrote:
>
>> 2012/2/23 Marek Szyprowski <m.szyprowski@samsung.com>:
>>
>>> This is (yet another) quick update of CMA patches. I've rebased them
>>> onto next-20120222 tree from
>>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git and
>>> fixed the bug pointed by Aaro Koskinen.
>>
>>
>> For the whole series:
>>
>> Tested-by: Barry Song <Baohua.Song@csr.com>
>>
>> and i also write a simple kernel helper to test the CMA:
>
>
> Would it make sense to make a patch out of it putting it to tools/cma (or
> similar)?

i can send a patch for this. i am just thinking, should it be placed
in tools/ as a test utility or Documents/ as an example to explain CMA
to users who want to use cma. i also think we should have a seperate
document to explain cma in details in documents/, and my helper
program can be placed there.

how do you think?
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

thanks
barry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
