Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A88076B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 18:07:24 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e1so1480075pfn.13
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 15:07:24 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o65sor883043pfb.96.2018.02.21.15.07.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 15:07:23 -0800 (PST)
Date: Thu, 22 Feb 2018 08:07:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] mm: zsmalloc: Replace return type int with bool
Message-ID: <20180221230717.GA27147@rodete-desktop-imager.corp.google.com>
References: <20180221195306.GA32070@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180221195306.GA32070@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: mhocko@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org

On Thu, Feb 22, 2018 at 01:23:07AM +0530, Souptick Joarder wrote:
> zs_register_migration() returns either 0 or 1.
> So the return type int should be replaced with bool.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

As I said earlier, it is lack of justfication.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
