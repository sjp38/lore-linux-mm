Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECBD46B4C7D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 05:29:24 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id h17so23392292qto.4
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 02:29:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o2si2657457qtd.403.2018.11.28.02.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 02:29:24 -0800 (PST)
Subject: Re: [PATCH] Small typo fix
References: <20181127210459.11809-1-ates@bu.edu>
From: David Hildenbrand <david@redhat.com>
Message-ID: <51b74f0d-669c-0e8e-f08a-628587a40700@redhat.com>
Date: Wed, 28 Nov 2018 11:29:21 +0100
MIME-Version: 1.0
In-Reply-To: <20181127210459.11809-1-ates@bu.edu>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emre Ates <ates@bu.edu>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On 27.11.18 22:04, Emre Ates wrote:
> ---
>  mm/vmstat.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 9c624595e904..cc7d04928c2e 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1106,7 +1106,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
>  					TEXT_FOR_HIGHMEM(xx) xx "_movable",
> 
>  const char * const vmstat_text[] = {
> -	/* enum zone_stat_item countes */
> +	/* enum zone_stat_item counters */
>  	"nr_free_pages",
>  	"nr_zone_inactive_anon",
>  	"nr_zone_active_anon",
> --
> 2.19.1
> 
> Signed-off-by: Emre Ates <ates@bu.edu>
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
