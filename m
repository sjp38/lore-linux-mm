Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id CA54C6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 10:31:30 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so2185813vcb.10
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:31:30 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id 3si3158776vcs.47.2014.05.30.07.31.29
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 07:31:30 -0700 (PDT)
Date: Fri, 30 May 2014 09:31:26 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 1/8] memcg: cleanup memcg_cache_params refcnt usage
In-Reply-To: <3c02e9f973fcce5691fbf4b6d33665174326c4d5.1401457502.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1405300931140.11943@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <3c02e9f973fcce5691fbf4b6d33665174326c4d5.1401457502.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 30 May 2014, Vladimir Davydov wrote:

> Currently, we count the number of pages allocated to a per memcg cache
> in memcg_cache_params->nr_pages. We only use this counter to find out if
> the cache is empty and can be destroyed. So let's rename it to refcnt
> and make it count not pages, but slabs so that we can use atomic_inc/dec
> instead of atomic_add/sub in memcg_charge/uncharge_slab.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
