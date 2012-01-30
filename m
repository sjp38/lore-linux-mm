Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 23AD26B005A
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 07:42:54 -0500 (EST)
Received: by eekc13 with SMTP id c13so1626966eek.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 04:42:52 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 03/15] mm: compaction: introduce
 isolate_migratepages_range().
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-4-git-send-email-m.szyprowski@samsung.com>
 <20120130112428.GF25268@csn.ul.ie>
Date: Mon, 30 Jan 2012 13:42:50 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v8wdlovn3l0zgt@mpn-glaptop>
In-Reply-To: <20120130112428.GF25268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

> On Thu, Jan 26, 2012 at 10:00:45AM +0100, Marek Szyprowski wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>> @@ -313,7 +316,7 @@ static isolate_migrate_t isolate_migratepages(str=
uct zone *zone,
>>  		} else if (!locked)
>>  			spin_lock_irq(&zone->lru_lock);
>>
>> -		if (!pfn_valid_within(low_pfn))
>> +		if (!pfn_valid(low_pfn))
>>  			continue;
>>  		nr_scanned++;
>>

On Mon, 30 Jan 2012 12:24:28 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> This chunk looks unrelated to the rest of the patch.
>
> I think what you are doing is patching around a bug that CMA exposed
> which is very similar to the bug report at
> http://www.spinics.net/lists/linux-mm/msg29260.html . Is this true?
>
> If so, I posted a fix that only calls pfn_valid() when necessary. Can
> you check if that works for you and if so, drop this hunk please? If
> the patch does not work for you, then this hunk still needs to be
> in a separate patch and handled separately as it would also be a fix
> for -stable.

I'll actually never encountered this bug myself and CMA is unlikely to
expose it, since it always operates on continuous memory regions with
no holes.

I've made this change because looking at the code it seemed like this
may cause problems in some cases.  The crash that you linked to looks
like the kind of problem I was thinking about.

I'll drop this hunk and let you resolve this independently of CMA.

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
