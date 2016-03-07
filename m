Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 334796B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 09:58:00 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l68so73622522wml.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 06:58:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u11si14647562wmd.41.2016.03.07.06.57.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 06:57:59 -0800 (PST)
Subject: Re: [PATCH] mm: remove __GFP_NOFAIL is deprecated comment
References: <1456397002-27172-1-git-send-email-mhocko@kernel.org>
 <56CEE72B.5040009@kyup.com> <20160225134850.GA4204@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DD96F4.1060805@suse.cz>
Date: Mon, 7 Mar 2016 15:57:56 +0100
MIME-Version: 1.0
In-Reply-To: <20160225134850.GA4204@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Nikolay Borisov <kernel@kyup.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 02/25/2016 02:48 PM, Michal Hocko wrote:
> On Thu 25-02-16 13:36:11, Nikolay Borisov wrote:
> -		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
> -			/*
> -			 * __GFP_NOFAIL is not to be used in new code.
> -			 *
> -			 * All __GFP_NOFAIL callers should be fixed so that they
> -			 * properly detect and handle allocation failures.
> -			 *
> -			 * We most definitely don't want callers attempting to
> -			 * allocate greater than order-1 page units with
> -			 * __GFP_NOFAIL.
> -			 */
> -			WARN_ON_ONCE(order > 1);
> -		}
> +		/*
> +		 * We most definitely don't want callers attempting to
> +		 * allocate greater than order-1 page units with __GFP_NOFAIL.
> +		 */
> +		WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
>   		spin_lock_irqsave(&zone->lock, flags);
>
>   		page = NULL;
>

Hmm, even the reduced text (and the WARN_ON in the first place) sounds 
IMHO discouraging enough to make people think that opencoding a loop 
around such allocations is a good workaround. Yeah, we have a 
better/more thorough explanation around the __GFP_NOFAIL definition, but 
the WARN_ON will point people here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
