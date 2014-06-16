Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 12DEB6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 19:07:59 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so394345igb.5
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 16:07:58 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id hg12si316320icb.17.2014.06.16.16.07.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 16:07:58 -0700 (PDT)
Received: by mail-ig0-f181.google.com with SMTP id h15so353783igd.8
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 16:07:58 -0700 (PDT)
Date: Mon, 16 Jun 2014 16:07:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: page_alloc: simplify drain_zone_pages by using
 min()
In-Reply-To: <1402952894-13200-1-git-send-email-mina86@mina86.com>
Message-ID: <alpine.DEB.2.02.1406161607430.21018@chino.kir.corp.google.com>
References: <1402952894-13200-1-git-send-email-mina86@mina86.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 16 Jun 2014, Michal Nazarewicz wrote:

> Instead of open-coding getting minimal value of two, just use min macro.
> That is why it is there for.  While changing the function also change
> type of batch local variable to match type of per_cpu_pages::batch
> (which is int).
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
