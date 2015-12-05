Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5647A6B0259
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 20:03:21 -0500 (EST)
Received: by wmww144 with SMTP id w144so81673539wmw.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 17:03:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b128si9247098wmd.90.2015.12.04.17.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 17:03:20 -0800 (PST)
Date: Fri, 4 Dec 2015 17:03:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg, vmscan: Do not wait for writeback if killed
Message-Id: <20151204170317.4bb1347cce4d4b3e03a18e1e@linux-foundation.org>
In-Reply-To: <20151203090826.GD9264@dhcp22.suse.cz>
References: <1449066378-4764-1-git-send-email-mhocko@kernel.org>
	<20151202142503.0921c0d6e06394ff7dff85fa@linux-foundation.org>
	<20151203090826.GD9264@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 3 Dec 2015 10:08:26 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> So you think a comment would be sufficient?
> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 98a1934493af..2e8ee9e5fcb5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1031,9 +1031,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				/*
>  				 * We've got killed while waiting here so
>  				 * expedite our way out from the reclaim
> +				 *
> +				 * Our callers should make sure we do not
> +				 * get here with fatal signals again.
>  				 */

Seems OK.  s/should/must/

Please resend it all after the usual exhaustive testing ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
