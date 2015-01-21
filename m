Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAC36B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 18:01:21 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id hn18so3959706igb.2
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 15:01:21 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id rv8si553414igb.30.2015.01.21.15.01.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jan 2015 15:01:20 -0800 (PST)
Received: by mail-ig0-f176.google.com with SMTP id hl2so23354268igb.3
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 15:01:20 -0800 (PST)
Date: Wed, 21 Jan 2015 15:01:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm/slub: fix typo
In-Reply-To: <20150120140142.cd2e32d83d66459562bd1717@freescale.com>
Message-ID: <alpine.DEB.2.10.1501211459370.2716@chino.kir.corp.google.com>
References: <20150120140142.cd2e32d83d66459562bd1717@freescale.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kim Phillips <kim.phillips@freescale.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Tue, 20 Jan 2015, Kim Phillips wrote:

> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>

Acked-by: David Rientjes <rientjes@google.com>

Although the patch description or title should probably say this is a typo 
in the comment of __slab_free().  It's good to differentiate typos in code 
vs comments for commit message readers who have to decide if they have to 
backport something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
