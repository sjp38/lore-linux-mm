Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 51AD36B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 19:32:24 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id h15so11938218igd.14
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 16:32:24 -0800 (PST)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id j4si20138489igg.4.2014.12.29.16.32.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 16:32:23 -0800 (PST)
Received: by mail-ie0-f171.google.com with SMTP id ar1so12909747iec.16
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 16:32:22 -0800 (PST)
Date: Mon, 29 Dec 2014 16:32:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/debug_pagealloc: remove obsolete Kconfig options
In-Reply-To: <1419310437-9193-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1412291632010.23782@chino.kir.corp.google.com>
References: <1419310437-9193-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Bolle <pebolle@tiscali.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 23 Dec 2014, Joonsoo Kim wrote:

> These are obsolete since commit e30825f1869a ("mm/debug-pagealloc:
> prepare boottime configurable on/off") is merged. Remove them.
> 
> Reported-by: Paul Bolle <pebolle@tiscali.nl>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
