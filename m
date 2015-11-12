Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C52B26B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 19:57:23 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so46511457pac.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 16:57:23 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id fj6si16049644pad.24.2015.11.11.16.57.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 16:57:23 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so46691970pab.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 16:57:22 -0800 (PST)
Date: Thu, 12 Nov 2015 09:58:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/3] tools/vm: fix Makefile multi-targets
Message-ID: <20151112005820.GB1651@swordfish>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1447162326-30626-2-git-send-email-sergey.senozhatsky@gmail.com>
 <20151111122807.GB654@swordfish>
 <alpine.DEB.2.10.1511111232460.3565@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511111232460.3565@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (11/11/15 12:34), David Rientjes wrote:
[..]
> 
> No, I have no objection to removing -O2.  I'd prefer that the rationale be 
> included in the commit description, however.

yes, agree. thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
