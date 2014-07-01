Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id CCB8E6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 18:26:29 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id at1so8794218iec.0
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:26:29 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id h5si18386707igg.14.2014.07.01.15.26.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 15:26:28 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id uq10so5984140igb.6
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:26:28 -0700 (PDT)
Date: Tue, 1 Jul 2014 15:26:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 4/9] slab: factor out initialization of arracy cache
In-Reply-To: <1404203258-8923-5-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1407011525350.4004@chino.kir.corp.google.com>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com> <1404203258-8923-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue, 1 Jul 2014, Joonsoo Kim wrote:

> Factor out initialization of array cache to use it in following patch.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Not sure what happened to my

Acked-by: David Rientjes <rientjes@google.com>

from http://marc.info/?l=linux-mm&m=139951195724487 and my comment still 
stands about s/arracy/array/ in the patch title.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
