Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 97D146B00C5
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:06:54 -0400 (EDT)
Received: by gxk12 with SMTP id 12so4784126gxk.4
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 14:06:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090824090121.61c6f0ea.randy.dunlap@oracle.com>
References: <200908241007.33844.ngupta@vflare.org>
	 <20090824090121.61c6f0ea.randy.dunlap@oracle.com>
Date: Mon, 24 Aug 2009 23:00:55 +0530
Message-ID: <d760cf2d0908241030u6efdd816i2bafdf0a0368e34@mail.gmail.com>
Subject: Re: [PATCH 0/4] compcache: compressed in-memory swapping
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 24, 2009 at 9:31 PM, Randy Dunlap<randy.dunlap@oracle.com> wrot=
e:
> On Mon, 24 Aug 2009 10:07:33 +0530 Nitin Gupta wrote:
>
>> (Sorry for long patch[2/4] but its now very hard to split it up).
>>
>> =A0Documentation/blockdev/00-INDEX =A0 =A0 =A0 | =A0 =A02 +
>> =A0Documentation/blockdev/ramzswap.txt =A0 | =A0 52 ++
>> =A0drivers/block/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 22 +
>> =A0drivers/block/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
>> =A0drivers/block/ramzswap/Makefile =A0 =A0 =A0 | =A0 =A02 +
>
> I can't find drivers/block/ramzswap/Makefile in the patches...
>

My bad. I missed it. Here it is:

obj-$(CONFIG_BLK_DEV_RAMZSWAP)  +=3D      ramzswap.o xvmalloc.o


I will send updated diffs with swap_lock fix in patch[3/4] with this Makefi=
le
include once I get additional reviews.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
