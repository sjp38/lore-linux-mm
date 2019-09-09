Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82BEDC4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:59:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E0F9218AF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:59:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E0F9218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3A7C6B0007; Mon,  9 Sep 2019 08:59:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEAC46B0008; Mon,  9 Sep 2019 08:59:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFF6E6B000A; Mon,  9 Sep 2019 08:59:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id 89E466B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:59:16 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 312236D9A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:59:16 +0000 (UTC)
X-FDA: 75915387912.16.cause35_8b16f81061947
X-HE-Tag: cause35_8b16f81061947
X-Filterd-Recvd-Size: 2649
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:59:15 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E08F0AFBA;
	Mon,  9 Sep 2019 12:59:13 +0000 (UTC)
Subject: Re: [PATCH v2 1/2] mm/page_ext: support to record the last stack of
 page
To: Walter Wu <walter-zh.wu@mediatek.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>, Will Deacon <will@kernel.org>,
 Andrey Konovalov <andreyknvl@google.com>, Arnd Bergmann <arnd@arndb.de>,
 Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>,
 Qian Cai <cai@lca.pw>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
 linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
References: <20190909085339.25350-1-walter-zh.wu@mediatek.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0fd84c7b-a23b-0b09-519f-a006fade1b4f@suse.cz>
Date: Mon, 9 Sep 2019 14:59:12 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190909085339.25350-1-walter-zh.wu@mediatek.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/9/19 10:53 AM, Walter Wu wrote:
> KASAN will record last stack of page in order to help programmer
> to see memory corruption caused by page.
> 
> What is difference between page_owner and our patch?
> page_owner records alloc stack of page, but our patch is to record
> last stack(it may be alloc or free stack of page).
> 
> Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>

There's no point in separating this from patch 2 (and as David pointed 
out, doesn't compile).

> ---
>   mm/page_ext.c | 3 +++
>   1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index 5f5769c7db3b..7ca33dcd9ffa 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -65,6 +65,9 @@ static struct page_ext_operations *page_ext_ops[] = {
>   #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
>   	&page_idle_ops,
>   #endif
> +#ifdef CONFIG_KASAN
> +	&page_stack_ops,
> +#endif
>   };
>   
>   static unsigned long total_usage;
> 


