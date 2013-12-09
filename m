Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6F81D6B00DE
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 14:50:19 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so3065456yho.38
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 11:50:19 -0800 (PST)
Received: from mail-yh0-x22b.google.com (mail-yh0-x22b.google.com [2607:f8b0:4002:c01::22b])
        by mx.google.com with ESMTPS id v1si10966973yhg.76.2013.12.09.11.50.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 11:50:18 -0800 (PST)
Received: by mail-yh0-f43.google.com with SMTP id a41so3044873yho.2
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 11:50:17 -0800 (PST)
Date: Mon, 9 Dec 2013 11:50:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add show num_poisoned_pages when oom
In-Reply-To: <52A592DE.7010302@huawei.com>
Message-ID: <alpine.DEB.2.02.1312091149440.2321@chino.kir.corp.google.com>
References: <52A592DE.7010302@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 9 Dec 2013, Xishi Qiu wrote:

> Show num_poisoned_pages when oom, it is helpful to find the reason.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

Although this patch says it's for oom conditions, it will be emitted 
anytime show_mem() is called which sounds good as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
