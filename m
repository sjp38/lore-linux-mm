Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9216B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:35:58 -0500 (EST)
Received: by pacej9 with SMTP id ej9so20159425pac.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:35:58 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ry10si319421pac.49.2015.12.01.15.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:35:57 -0800 (PST)
Received: by pacej9 with SMTP id ej9so20159227pac.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:35:57 -0800 (PST)
Date: Tue, 1 Dec 2015 15:35:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: fix warning in comparing enumerator
In-Reply-To: <20151201230742.GA13514@www9186uo.sakura.ne.jp>
Message-ID: <alpine.DEB.2.10.1512011535420.23632@chino.kir.corp.google.com>
References: <1448959032-754-1-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.10.1512011425230.19510@chino.kir.corp.google.com> <20151201230742.GA13514@www9186uo.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <nao.horiguchi@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2 Dec 2015, Naoya Horiguchi wrote:

> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Subject: [PATCH v2] mm: fix warning in comparing enumerator
> 
> I saw the following warning when building mmotm-2015-11-25-17-08.
> 
> mm/page_alloc.c:4185:16: warning: comparison between 'enum zone_type' and 'enum <anonymous>' [-Wenum-compare]
>   for (i = 0; i < MAX_ZONELISTS; i++) {
>                 ^
> 
> enum zone_type is named like ZONE_* which is different from ZONELIST_*, so
> we are somehow doing incorrect comparison. Just fixes it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
