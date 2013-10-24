Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9C57A6B00E0
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 13:31:32 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so940167pde.31
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 10:31:32 -0700 (PDT)
Received: from psmtp.com ([74.125.245.106])
        by mx.google.com with SMTP id ws5si2510409pab.122.2013.10.24.10.31.31
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 10:31:31 -0700 (PDT)
Message-ID: <5269596F.6090206@iki.fi>
Date: Thu, 24 Oct 2013 20:31:27 +0300
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] memcg, kmem: use cache_from_memcg_idx instead of
 hard code
References: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com> <1382527875-10112-4-git-send-email-h.huangqiang@huawei.com>
In-Reply-To: <1382527875-10112-4-git-send-email-h.huangqiang@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org, penberg@kernel.org, glommer@parallels.com, rientjes@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On 10/23/2013 02:31 PM, Qiang Huang wrote:
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
