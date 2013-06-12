Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 2D9F66B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 16:16:36 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kl14so3905151pab.34
        for <linux-mm@kvack.org>; Wed, 12 Jun 2013 13:16:35 -0700 (PDT)
Date: Wed, 12 Jun 2013 13:16:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Remove zone_type argument of build_zonelists_node
In-Reply-To: <51B86456.3060606@gmail.com>
Message-ID: <alpine.DEB.2.02.1306121316230.23348@chino.kir.corp.google.com>
References: <51B86456.3060606@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 12 Jun 2013, Zhang Yanfei wrote:

> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> The callers of build_zonelists_node always pass MAX_NR_ZONES -1
> as the zone_type argument, so we can directly use the value
> in build_zonelists_node and remove zone_type argument.
> 
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
