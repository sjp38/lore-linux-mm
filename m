Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0356B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 14:40:30 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id q59so2600322wes.37
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 11:40:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id md18si2009704wic.30.2014.02.07.11.40.28
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 11:40:29 -0800 (PST)
Message-ID: <52F5366D.9010300@redhat.com>
Date: Fri, 07 Feb 2014 14:39:25 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix page leak at nfs_symlink()
References: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
In-Reply-To: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, linux-kernel@vger.kernel.org
Cc: trond.myklebust@primarydata.com, jstancek@redhat.com, jlayton@redhat.com, mgorman@suse.de, linux-nfs@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On 02/07/2014 10:19 AM, Rafael Aquini wrote:
> Changes committed by "a0b8cab3 mm: remove lru parameter from
> __pagevec_lru_add and remove parts of pagevec API" have introduced
> a call to add_to_page_cache_lru() which causes a leak in nfs_symlink()
> as now the page gets an extra refcount that is not dropped.
>
> Jan Stancek observed and reported the leak effect while running test8 from
> Connectathon Testsuite. After several iterations over the test case,
> which creates several symlinks on a NFS mountpoint, the test system was
> quickly getting into an out-of-memory scenario.
>
> This patch fixes the page leak by dropping that extra refcount
> add_to_page_cache_lru() is grabbing.
>
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
