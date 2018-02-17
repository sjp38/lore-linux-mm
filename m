Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 483386B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 19:28:13 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v16so2492071wrv.14
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 16:28:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 17si10609265wmg.167.2018.02.16.16.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 16:28:12 -0800 (PST)
Date: Fri, 16 Feb 2018 16:28:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: limit use of stale list for allocation
Message-Id: <20180216162809.30b2278f0cacefa66c95c1aa@linux-foundation.org>
In-Reply-To: <47ab51e7-e9c1-d30e-ab17-f734dbc3abce@gmail.com>
References: <47ab51e7-e9c1-d30e-ab17-f734dbc3abce@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Oleksiy.Avramchenko@sony.com

On Sat, 10 Feb 2018 12:02:52 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:

> Currently if z3fold couldn't find an unbuddied page it would first
> try to pull a page off the stale list. The problem with this
> approach is that we can't 100% guarantee that the page is not
> processed by the workqueue thread at the same time unless we run
> cancel_work_sync() on it, which we can't do if we're in an atomic
> context. So let's just limit stale list usage to non-atomic
> contexts only.

This smells like a bugfix.  What are the end-user visible effects of
the bug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
