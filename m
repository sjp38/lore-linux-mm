Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EE0B16B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 04:36:11 -0400 (EDT)
Received: by pzk10 with SMTP id 10so2884711pzk.19
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 01:36:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1253600030.30406.2.camel@penberg-laptop>
References: <1253595414-2855-1-git-send-email-ngupta@vflare.org>
	 <1253600030.30406.2.camel@penberg-laptop>
Date: Tue, 22 Sep 2009 14:06:12 +0530
Message-ID: <d760cf2d0909220136g38c0541bxab93f9b5a2b22d7@mail.gmail.com>
Subject: Re: [PATCH 0/3] compcache: in-memory compressed swapping v4
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Marcin Slusarz <marcin.slusarz@gmail.com>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 11:43 AM, Pekka Enberg <penberg@cs.helsinki.fi> wro=
te:
> On Tue, 2009-09-22 at 10:26 +0530, Nitin Gupta wrote:
>> =A0drivers/staging/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
2 +
>> =A0drivers/staging/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
1 +
>> =A0drivers/staging/ramzswap/Kconfig =A0 =A0 =A0 =A0 =A0| =A0 21 +
>> =A0drivers/staging/ramzswap/Makefile =A0 =A0 =A0 =A0 | =A0 =A03 +
>> =A0drivers/staging/ramzswap/ramzswap.txt =A0 =A0 | =A0 51 +
>> =A0drivers/staging/ramzswap/ramzswap_drv.c =A0 | 1462 ++++++++++++++++++=
+++++++++++
>> =A0drivers/staging/ramzswap/ramzswap_drv.h =A0 | =A0173 ++++
>> =A0drivers/staging/ramzswap/ramzswap_ioctl.h | =A0 50 +
>> =A0drivers/staging/ramzswap/xvmalloc.c =A0 =A0 =A0 | =A0533 +++++++++++
>> =A0drivers/staging/ramzswap/xvmalloc.h =A0 =A0 =A0 | =A0 30 +
>> =A0drivers/staging/ramzswap/xvmalloc_int.h =A0 | =A0 86 ++
>> =A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A05 +
>> =A0mm/swapfile.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 34 +
>> =A013 files changed, 2451 insertions(+), 0 deletions(-)
>
> This diffstat is not up to date, I think.
>

Oh! this is from v3. I forgot to update it. I don't have access to my git t=
ree
here in office, so cannot send updated version right now.

> Greg, would you mind taking this driver into staging? There are some
> issues that need to be ironed out for it to be merged to kernel proper
> but I think it would benefit from being exposed to mainline.
>
> Nitin, you probably should also submit a patch that adds a TODO file
> similar to other staging drivers to remind us that swap notifiers and
> the CONFIG_ARM thing need to be resolved.
>

ok, I will send patch for TODO file.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
