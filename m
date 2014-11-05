Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 279B76B0098
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 11:51:35 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id x19so1091503ier.30
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 08:51:34 -0800 (PST)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id f13si6311370ick.66.2014.11.05.08.51.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 08:51:33 -0800 (PST)
Date: Wed, 5 Nov 2014 10:51:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: slub: fix format mismatches in slab_err() callers
In-Reply-To: <1415200341-9619-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1411051051140.27561@gentwo.org>
References: <1415200341-9619-1-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 5 Nov 2014, Andrey Ryabinin wrote:

> Adding __printf(3, 4) to slab_err exposed following:

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
