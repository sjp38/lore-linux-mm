Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBE91C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:08:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9AAA20863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:08:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9AAA20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 682246B0008; Mon,  9 Sep 2019 11:08:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60C376B000A; Mon,  9 Sep 2019 11:08:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 521D66B000C; Mon,  9 Sep 2019 11:08:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0132.hostedemail.com [216.40.44.132])
	by kanga.kvack.org (Postfix) with ESMTP id 2A98D6B0008
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:08:42 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CABB363F0
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:08:41 +0000 (UTC)
X-FDA: 75915714042.29.trail52_6900975741807
X-HE-Tag: trail52_6900975741807
X-Filterd-Recvd-Size: 2397
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:08:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D7039AFBB;
	Mon,  9 Sep 2019 15:08:38 +0000 (UTC)
Subject: Re: [PATCH 4/5] mm, slab_common: Make 'type' is enum
 kmalloc_cache_type
To: Pengfei Li <lpf.vector@gmail.com>, akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190903160430.1368-1-lpf.vector@gmail.com>
 <20190903160430.1368-5-lpf.vector@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <02c8e192-542c-4225-4718-67cc00f4dc17@suse.cz>
Date: Mon, 9 Sep 2019 17:08:38 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190903160430.1368-5-lpf.vector@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/3/19 6:04 PM, Pengfei Li wrote:
> The 'type' of the function new_kmalloc_cache should be
> enum kmalloc_cache_type instead of int, so correct it.

OK

> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/slab_common.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 8b542cfcc4f2..af45b5278fdc 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1192,7 +1192,7 @@ void __init setup_kmalloc_cache_index_table(void)
>   }
>   
>   static void __init
> -new_kmalloc_cache(int idx, int type, slab_flags_t flags)
> +new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t flags)
>   {
>   	if (type == KMALLOC_RECLAIM)
>   		flags |= SLAB_RECLAIM_ACCOUNT;
> @@ -1210,7 +1210,8 @@ new_kmalloc_cache(int idx, int type, slab_flags_t flags)
>    */
>   void __init create_kmalloc_caches(slab_flags_t flags)
>   {
> -	int i, type;
> +	int i;
> +	enum kmalloc_cache_type type;
>   
>   	for (type = KMALLOC_NORMAL; type <= KMALLOC_RECLAIM; type++) {
>   		for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
> 


