Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id F0ACF6B00DF
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 13:31:09 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so326253pbc.23
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 10:31:09 -0700 (PDT)
Received: from psmtp.com ([74.125.245.137])
        by mx.google.com with SMTP id yj4si2490465pac.253.2013.10.24.10.31.08
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 10:31:09 -0700 (PDT)
Message-ID: <52695958.50004@iki.fi>
Date: Thu, 24 Oct 2013 20:31:04 +0300
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] memcg, kmem: rename cache_from_memcg to cache_from_memcg_idx
References: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com> <1382527875-10112-3-git-send-email-h.huangqiang@huawei.com>
In-Reply-To: <1382527875-10112-3-git-send-email-h.huangqiang@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org, penberg@kernel.org, glommer@parallels.com, rientjes@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On 10/23/2013 02:31 PM, Qiang Huang wrote:
> We can't see the relationship with memcg from the parameters,
> so the name with memcg_idx would be more reasonable.
>
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
