Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 048286B002C
	for <linux-mm@kvack.org>; Sat,  4 Feb 2012 04:09:04 -0500 (EST)
Received: by wera13 with SMTP id a13so4376729wer.14
        for <linux-mm@kvack.org>; Sat, 04 Feb 2012 01:09:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v830ygma3l0zgt@mpn-glaptop>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
	<1328271538-14502-9-git-send-email-m.szyprowski@samsung.com>
	<CAJd=RBByc_wLEJTK66J4eY03CWnCoCRiwAeEYjXCZ5xEZhp3ag@mail.gmail.com>
	<op.v830ygma3l0zgt@mpn-glaptop>
Date: Sat, 4 Feb 2012 17:09:02 +0800
Message-ID: <CAJd=RBD765rmiCDiCz87Vf8vf8Wp-AiW=gZ3Nw5LjTPw70ZO7g@mail.gmail.com>
Subject: Re: [PATCH 08/15] mm: mmzone: MIGRATE_CMA migration type added
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2012/2/3 Michal Nazarewicz <mina86@mina86.com>:
>>> +static inline bool migrate_async_suitable(int migratetype)
>
> On Fri, 03 Feb 2012 15:19:54 +0100, Hillf Danton <dhillf@gmail.com> wrote:
>>
>> Just nitpick, since the helper is not directly related to what async
>> means,
>> how about migrate_suitable(int migrate_type) ?
>
>
> I feel current name is better suited since it says that it's OK to scan this
> block if it's an asynchronous compaction run.
>

The input is the migrate type of page considered, and the async is only one
of the modes that compaction should be carried out. Plus the helper is
also used in other cases where async is entirely not concerned.

That said, the naming is not clear, if not misleading.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
