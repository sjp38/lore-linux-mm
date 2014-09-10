Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4376B00AB
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 17:03:22 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id x13so7084135qcv.27
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:03:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g94si20153759qgd.7.2014.09.10.14.03.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 14:03:21 -0700 (PDT)
Message-ID: <5410B54E.1020607@redhat.com>
Date: Wed, 10 Sep 2014 16:32:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: page_alloc: Make paranoid check in move_freepages
 a VM_BUG_ON
References: <20140909145228.GB12309@suse.de>
In-Reply-To: <20140909145228.GB12309@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linuxfoundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/09/2014 10:52 AM, Mel Gorman wrote:
> Since 2.6.24 there has been a paranoid check in move_freepages that looks
> up the zone of two pages. This is a very slow path and the only time I've
> seen this bug trigger recently is when memory initialisation was broken
> during patch development. Despite the fact it's a slow path, this patch
> converts the check to a VM_BUG_ON anyway as it is served its purpose by now.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
