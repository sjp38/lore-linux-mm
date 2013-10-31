Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id C0FC86B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 22:35:47 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id jt11so2259324pbb.15
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 19:35:47 -0700 (PDT)
Received: from psmtp.com ([74.125.245.195])
        by mx.google.com with SMTP id ei3si558008pbc.20.2013.10.30.19.35.46
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 19:35:46 -0700 (PDT)
Received: by mail-pb0-f48.google.com with SMTP id mc17so2268463pbc.21
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 19:35:45 -0700 (PDT)
Date: Wed, 30 Oct 2013 19:35:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] memcg, kmem: Use is_root_cache instead of hard
 code
In-Reply-To: <1382527875-10112-2-git-send-email-h.huangqiang@huawei.com>
Message-ID: <alpine.DEB.2.02.1310301935300.18783@chino.kir.corp.google.com>
References: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com> <1382527875-10112-2-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org, penberg@kernel.org, glommer@parallels.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Wed, 23 Oct 2013, Qiang Huang wrote:

> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
