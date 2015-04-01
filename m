Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id C5C366B0038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 23:29:09 -0400 (EDT)
Received: by igcau2 with SMTP id au2so37140886igc.0
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 20:29:09 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id b19si801838ign.50.2015.03.31.20.29.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 20:29:09 -0700 (PDT)
Received: by iedm5 with SMTP id m5so33127422ied.3
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 20:29:09 -0700 (PDT)
Date: Tue, 31 Mar 2015 20:29:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 21/25] slub: Use bool function return values of true/false
 not 1/0
In-Reply-To: <e5d4c7a9a3496ac77ad5a07ce7f917b694053558.1427759010.git.joe@perches.com>
Message-ID: <alpine.DEB.2.10.1503312028550.24341@chino.kir.corp.google.com>
References: <cover.1427759009.git.joe@perches.com> <e5d4c7a9a3496ac77ad5a07ce7f917b694053558.1427759010.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 30 Mar 2015, Joe Perches wrote:

> Use the normal return values for bool functions
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
