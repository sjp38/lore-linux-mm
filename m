Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD516B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 14:38:56 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id lj1so3050445pab.23
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 11:38:55 -0700 (PDT)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id zl8si5204202pac.135.2014.09.25.11.38.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 11:38:55 -0700 (PDT)
Date: Thu, 25 Sep 2014 13:38:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: use IS_ENABLED() instead of ZONE_DMA_FLAG
In-Reply-To: <1411667851.2020.6.camel@x41>
Message-ID: <alpine.DEB.2.11.1409251338370.22503@gentwo.org>
References: <1411667851.2020.6.camel@x41>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 25 Sep 2014, Paul Bolle wrote:

> The Kconfig symbol ZONE_DMA_FLAG probably predates the introduction of
> IS_ENABLED(). Remove it and replace its two uses with the equivalent
> IS_ENABLED(CONFIG_ZONE_DMA).

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
