Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6086B0069
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 13:09:34 -0500 (EST)
Received: by bke17 with SMTP id 17so6293516bke.14
        for <linux-mm@kvack.org>; Sat, 19 Nov 2011 10:09:30 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [Linaro-mm-sig] [PATCHv17 0/11] Contiguous Memory Allocator
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <CA+K6fF6SH6BNoKgwArcqvyav4b=C5SGvymo5LS3akfD_yE_beg@mail.gmail.com>
 <op.v45u6zyy3l0zgt@mpn-glaptop>
 <CA+K6fF6iDivqmN9kfY34tWNg+g_rYBBmyS_Mxb6gvLuSgA2JyQ@mail.gmail.com>
Date: Sat, 19 Nov 2011 19:09:23 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v47gpxi03l0zgt@mpn-glaptop>
In-Reply-To: <CA+K6fF6iDivqmN9kfY34tWNg+g_rYBBmyS_Mxb6gvLuSgA2JyQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sandeep patil <psandeep.s@gmail.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Dave
 Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA
 Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

>> On Fri, 18 Nov 2011 22:20:48 +0100, sandeep patil wrote:
>>> So, i guess my question is, until all the migration failures are
>>> tracked down and fixed, is there a plan to retry the contiguous
>>> allocation from a new range in the CMA region?

> 2011/11/18 Michal Nazarewicz <mina86@mina86.com>:
>> No.  Current CMA implementation will stick to the same range of pages=
 also
>> on consequent allocations of the same size.

On Sat, 19 Nov 2011 00:30:49 +0100, sandeep patil <psandeep.s@gmail.com>=
 wrote:
> Doesn't that mean the drivers that fail to allocate from contiguous DM=
A region
> will fail, if the migration fails?

Yes.

I have some ideas how that could be mitigated.  The easiest would be to =
try
another region to allocate from on failure.  More complicated could be t=
o try
and wait for the I/O transfer to finish.  I'll try to work on it during
upcoming week.

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
