Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 850066B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 07:33:10 -0500 (EST)
Received: by eaaa11 with SMTP id a11so1627070eaa.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 04:33:08 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 05/15] mm: compaction: export some of the functions
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-6-git-send-email-m.szyprowski@samsung.com>
 <20120130115726.GI25268@csn.ul.ie>
Date: Mon, 30 Jan 2012 13:33:06 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v8wc5guk3l0zgt@mpn-glaptop>
In-Reply-To: <20120130115726.GI25268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

> On Thu, Jan 26, 2012 at 10:00:47AM +0100, Marek Szyprowski wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -16,30 +16,11 @@
>>  #include <linux/sysfs.h>
>>  #include "internal.h"
>>
>> +#if defined CONFIG_COMPACTION || defined CONFIG_CMA
>> +

On Mon, 30 Jan 2012 12:57:26 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> This is pedantic but you reference CONFIG_CMA before the patch that
> declares it. The only time this really matters is when it breaks
> bisection but I do not think that is the case here.

I think I'll choose to be lazy on this one. ;) I actually tried to move
some commits around to resolve this future-reference, but this resulted
in quite a few conflicts during rebase and after several minutes I decid=
ed
that it's not worth the effort.

> Whether you fix this or not by moving the CONFIG_CMA check to the same=

> patch that declares it in Kconfig
>
> Acked-by: Mel Gorman <mel@csn.ul.ie>

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
