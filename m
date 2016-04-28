Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 164156B0253
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 12:21:28 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i22so183101840ywc.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:21:28 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0067.outbound.protection.outlook.com. [157.55.234.67])
        by mx.google.com with ESMTPS id b66si5267827qkd.55.2016.04.28.09.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 28 Apr 2016 09:21:27 -0700 (PDT)
Subject: Re: [PATCH 15/20] tile: get rid of superfluous __GFP_REPEAT
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
 <1461849846-27209-16-git-send-email-mhocko@kernel.org>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <7390db4d-9035-6f09-8f0d-134d2bdeccf7@mellanox.com>
Date: Thu, 28 Apr 2016 12:21:11 -0400
MIME-Version: 1.0
In-Reply-To: <1461849846-27209-16-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org

On 4/28/2016 9:24 AM, Michal Hocko wrote:
> From: Michal Hocko<mhocko@suse.com>
>
> __GFP_REPEAT has a rather weak semantic but since it has been introduced
> around 2.6.12 it has been ignored for low order allocations.
>
> pgtable_alloc_one uses __GFP_REPEAT flag for L2_USER_PGTABLE_ORDER but
> the order is either 0 or 3 if L2_KERNEL_PGTABLE_SHIFT for HPAGE_SHIFT.
> This means that this flag has never been actually useful here because it
> has always been used only for PAGE_ALLOC_COSTLY requests.
>
> Cc: Chris Metcalf<cmetcalf@mellanox.com>
> Cc:linux-arch@vger.kernel.org
> Signed-off-by: Michal Hocko<mhocko@suse.com>
> ---
>   arch/tile/mm/pgtable.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

This seems OK as far as I can tell from code review.

Acked-by: Chris Metcalf <cmetcalf@mellanox.com> [for tile]

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
