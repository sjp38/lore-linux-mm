Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C476B6B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 22:40:59 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1856150pad.30
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 19:40:59 -0700 (PDT)
Received: from psmtp.com ([74.125.245.190])
        by mx.google.com with SMTP id mj9si877000pab.103.2013.10.30.19.40.57
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 19:40:57 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so1850099pad.39
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 19:40:56 -0700 (PDT)
Date: Wed, 30 Oct 2013 19:40:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] memcg, kmem: use cache_from_memcg_idx instead of
 hard code
In-Reply-To: <1382527875-10112-4-git-send-email-h.huangqiang@huawei.com>
Message-ID: <alpine.DEB.2.02.1310301940400.18783@chino.kir.corp.google.com>
References: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com> <1382527875-10112-4-git-send-email-h.huangqiang@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org, penberg@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Wed, 23 Oct 2013, Qiang Huang wrote:

> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
